import 'package:photohunt_stack/env.dart';
import 'package:photohunt_stack/release.dart';
import 'package:photohunt_stack/stack.dart';
import 'package:test/test.dart';

const _digest =
    'sha256:0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';

Map<String, Object?> _synth({bool maintenance = false}) {
  final release = Release(
    apiImage: '${Env.prod.imageRepository}/api@$_digest',
    releaseId: 'abcdef1',
    maintenanceMode: maintenance,
  );
  return PhotohuntStack(env: Env.prod, release: release).synth().tfJson;
}

/// JSON の値を Map として読む。形が違えばテストを失敗させる（`as` で型を決めつけない）。
Map<String, Object?> _map(Object? value) => switch (value) {
  final Map<String, Object?> map => map,
  _ => throw StateError('Map ではない: $value'),
};

List<Object?> _list(Object? value) => switch (value) {
  final List<Object?> list => list,
  _ => throw StateError('List ではない: $value'),
};

/// Terraform の型ごとの resource ブロック。
Map<String, Map<String, Object?>> _resources(
  Map<String, Object?> json,
  String type,
) => {
  for (final MapEntry(:key, :value) in _map(
    _map(json['resource'])[type],
  ).entries)
    key: _map(value),
};

/// サービスの template、または Job の template.template にあるコンテナ（1 つだけ）。
Map<String, Object?> _container(Map<String, Object?> template) =>
    _map(_list(template['containers']).single);

Map<String, Object?> _serviceContainer(Map<String, Object?> json) => _container(
  _map(_resources(json, 'google_cloud_run_v2_service')['api']?['template']),
);

List<Map<String, Object?>> _env(Map<String, Object?> container) => [
  for (final e in _list(container['env'])) _map(e),
];

Map<String, Object?> _plainEnv(Map<String, Object?> container) => {
  for (final e in _env(container))
    if (e['value'] case final String value) '${e['name']}': value,
};

void main() {
  group('Release.fromEnvironment', () {
    final image = '${Env.prod.imageRepository}/api@$_digest';

    test('digest 指定の image とコミット SHA を受け付ける', () {
      final release = Release.fromEnvironment({
        'API_IMAGE': image,
        'RELEASE_ID': 'abcdef1234',
        'MAINTENANCE_MODE': 'true',
      }, Env.prod);
      expect(release.apiImage, image);
      expect(release.maintenanceMode, isTrue);
    });

    test('MAINTENANCE_MODE の既定は false', () {
      final release = Release.fromEnvironment({
        'API_IMAGE': image,
        'RELEASE_ID': 'abcdef1',
      }, Env.prod);
      expect(release.maintenanceMode, isFalse);
    });

    for (final (label, environment) in [
      ('API_IMAGE がない', {'RELEASE_ID': 'abcdef1'}),
      (
        'タグ指定',
        {
          'API_IMAGE': '${Env.prod.imageRepository}/api:latest',
          'RELEASE_ID': 'abcdef1',
        },
      ),
      (
        '別の repository',
        {'API_IMAGE': 'gcr.io/x/api@$_digest', 'RELEASE_ID': 'abcdef1'},
      ),
      ('RELEASE_ID がない', {'API_IMAGE': image}),
      (
        'MAINTENANCE_MODE が不正',
        {
          'API_IMAGE': image,
          'RELEASE_ID': 'abcdef1',
          'MAINTENANCE_MODE': 'yes',
        },
      ),
    ]) {
      test('$label なら拒否する', () {
        expect(
          () => Release.fromEnvironment(environment, Env.prod),
          throwsA(isA<ReleaseException>()),
        );
      });
    }
  });

  group('PhotohuntStack', () {
    final json = _synth();

    test('state は tfstate バケットの stack/prod に置く', () {
      expect(_map(json['terraform'])['backend'], {
        'gcs': {'bucket': Env.prod.stateBucket, 'prefix': 'stack/prod'},
      });
    });

    test('DB バケットは匿名で読めず、素材バケットは公開する', () {
      final db = _resources(json, 'google_storage_bucket')['db'];
      expect(db?['public_access_prevention'], 'enforced');
      expect(db?['force_destroy'], isFalse);
      final publicMembers = _resources(
        json,
        'google_storage_bucket_iam_member',
      ).values.where((m) => m['member'] == 'allUsers');
      expect(publicMembers, hasLength(1));
      expect(
        publicMembers.single['bucket'],
        contains('google_storage_bucket.media'),
      );
    });

    test('API の実行 SA に素材の書き込み権限を与えず、seed Job には作成だけを許す', () {
      final media = _resources(
        json,
        'google_storage_bucket_iam_member',
      ).values.where((m) => '${m['bucket']}'.contains('.media.'));
      expect(media.where((m) => '${m['member']}'.contains('sa-api')), isEmpty);
      final migrate = media.where(
        (m) => '${m['member']}'.contains('sa-migrate'),
      );
      expect(migrate.map((m) => m['role']), ['roles/storage.objectCreator']);
    });

    test('seed の入力は非公開のバケットに置き、seed Job だけが読み取り専用でマウントする', () {
      final seedsBucket = _resources(json, 'google_storage_bucket')['seeds'];
      expect(seedsBucket?['public_access_prevention'], 'enforced');
      final seedsMembers = _resources(
        json,
        'google_storage_bucket_iam_member',
      ).values.where((m) => '${m['bucket']}'.contains('.seeds.'));
      // 素材担当（mediaUploaders）を登録しても崩れないよう、SA ごとに確かめる。
      expect(
        seedsMembers.where((m) => '${m['member']}'.contains('sa-api')),
        isEmpty,
      );
      final migrate = seedsMembers.where(
        (m) =>
            m['member'] == 'serviceAccount:${Env.prod.migrateServiceAccount}',
      );
      expect(migrate.map((m) => m['role']), ['roles/storage.objectViewer']);
      expect(seedsMembers.where((m) => m['member'] == 'allUsers'), isEmpty);

      final jobs = _resources(json, 'google_cloud_run_v2_job');
      final seedTemplate = _map(_map(jobs['seed']?['template'])['template']);
      expect(seedTemplate['volumes'], [
        {
          'name': 'seeds',
          'gcs': {
            'bucket': r'${google_storage_bucket.seeds.name}',
            'read_only': true,
          },
        },
      ]);
      expect(_container(seedTemplate)['volume_mounts'], [
        {'mount_path': '/content/seeds', 'name': 'seeds'},
      ]);
      final migrateTemplate = _map(
        _map(jobs['migrate']?['template'])['template'],
      );
      expect(migrateTemplate.containsKey('volumes'), isFalse);
    });

    test('Cloud Run は仕様の既定値で、トラフィックを IaC で管理しない', () {
      final api = _map(_resources(json, 'google_cloud_run_v2_service')['api']);
      expect(_map(api['lifecycle'])['ignore_changes'], contains('traffic'));
      expect(api.containsKey('traffic'), isFalse);
      final template = _map(api['template']);
      expect(template['scaling'], {
        'min_instance_count': 0,
        'max_instance_count': 1,
      });
      expect(template['max_instance_request_concurrency'], 10);
      expect(template['timeout'], '120s');
      final container = _container(template);
      expect(_map(container['resources'])['cpu_idle'], isFalse);
      expect(container['image'], endsWith(_digest));
    });

    test('サービスと Job は同じ image と同じ DB 系の環境変数を使う', () {
      final apiContainer = _serviceContainer(json);
      final jobs = _resources(json, 'google_cloud_run_v2_job');
      expect(jobs.keys, containsAll(['migrate', 'seed']));
      for (final job in jobs.values) {
        final template = _map(_map(job['template'])['template']);
        final container = _container(template);
        expect(container['image'], apiContainer['image']);
        for (final key in [
          'DB_REPLICA_BUCKET',
          'DB_REPLICA_PREFIX',
          'DB_WRITER_OWNER_OBJECT',
          'RELEASE_ID',
        ]) {
          expect(
            _plainEnv(container)[key],
            _plainEnv(apiContainer)[key],
            reason: key,
          );
        }
        expect(template['max_retries'], 0);
      }
    });

    test('秘密は Secret Manager の固定版で渡し、値を持たない', () {
      final secrets = _env(_serviceContainer(json))
          .where((e) => '${e['name']}'.startsWith('SERVERPOD_PASSWORD_'));
      expect(secrets, hasLength(2));
      for (final s in secrets) {
        expect(s.containsKey('value'), isFalse);
        final ref = _map(_map(s['value_source'])['secret_key_ref']);
        expect(ref['version'], isNot('latest'));
        expect(ref['version'], isNot('null'));
      }
      expect(json.toString(), isNot(contains('secret_data')));
    });

    test('保守モードはサービスだけに MAINTENANCE_MODE=true として渡し、Job の定義は変えない', () {
      final normal = _synth();
      final maintenance = _synth(maintenance: true);
      expect(
        _plainEnv(_serviceContainer(maintenance))['MAINTENANCE_MODE'],
        'true',
      );
      expect(
        _resources(maintenance, 'google_cloud_run_v2_job'),
        _resources(normal, 'google_cloud_run_v2_job'),
      );
    });

    test('サービスと Job は、secret と DB バケットの権限付与の後に作る', () {
      final grants = [
        ...{
          for (final key in _resources(
            json,
            'google_storage_bucket_iam_member',
          ).keys.where((k) => k.startsWith('db_')))
            'google_storage_bucket_iam_member.$key',
        },
        ...{
          for (final key in _resources(
            json,
            'google_secret_manager_secret_iam_member',
          ).keys)
            'google_secret_manager_secret_iam_member.$key',
        },
      ];
      expect(grants, hasLength(6));
      final api = _resources(json, 'google_cloud_run_v2_service')['api'];
      expect(api?['depends_on'], unorderedEquals(grants));
      final jobs = _resources(json, 'google_cloud_run_v2_job');
      expect(jobs['migrate']?['depends_on'], unorderedEquals(grants));
      // seed は seed の入力の読み取りと、素材バケットへの作成の付与も待つ。
      expect(
        jobs['seed']?['depends_on'],
        unorderedEquals([
          ...grants,
          'google_storage_bucket_iam_member.seeds_reader',
          'google_storage_bucket_iam_member.media_seed',
        ]),
      );
    });

    test('migrate Job は migration CLI を実行し、既定は apply', () {
      final job = _resources(json, 'google_cloud_run_v2_job')['migrate'];
      final container = _container(_map(_map(job?['template'])['template']));
      expect(container['command'], ['/app/migrate/bin/migrate']);
      expect(container['args'], ['apply']);
    });

    test('アプリへの出力は公開値だけ', () {
      final defines = _map(_map(_map(json['output'])['dart_defines'])['value']);
      expect(defines.keys, unorderedEquals(['API_BASE_URL', 'ASSET_BASE_URL']));
    });

    test('外形監視を置かない', () {
      expect(
        _map(json['resource'])
            .containsKey('google_monitoring_uptime_check_config'),
        isFalse,
      );
    });
  });
}
