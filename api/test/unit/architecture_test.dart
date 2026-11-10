import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:test/test.dart';

/// api のレイヤー間の依存方向（docs/specs.md「リポジトリ内の責務」）を検査する。
///
/// analyzer プラグインは、解析の完了通知がプラグインの結果より先に出ることがあり、
/// `dart analyze` が違反を見逃すため、CI の判定には unit テストを使う（#51）。
void main() {
  group('検査の仕組み', () {
    test('相対 import の違反を見つける', () {
      final found = _violationsOf(
        'src/domain/models/shot.dart',
        "import '../../infrastructure/database/unique_violation.dart';",
      );
      expect(found, [contains('package:photohunt_server/src/infrastructure/')]);
    });

    test('package: 形式の import の違反を見つける', () {
      final found = _violationsOf(
        'src/application/usecase/start.dart',
        "import 'package:photohunt_server/src/presentation/di/x.dart';",
      );
      expect(found, hasLength(1));
    });

    test('export・part・条件付き import の違反も見つける', () {
      final found = _violationsOf('src/domain/models/models.dart', '''
import 'a.dart' if (dart.library.io) '../../presentation/y.dart';
export '../../generated/protocol.dart';
part '../../infrastructure/x.dart';
''');
      expect(found, hasLength(3));
    });

    test('serverpod 系パッケージへの依存を見つける', () {
      final found = _violationsOf('src/domain/x.dart', '''
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
''');
      expect(found, hasLength(2));
    });

    test('許可された参照とコメントは違反にしない', () {
      expect(
        _violationsOf('src/domain/models/shot.dart', '''
// import '../../infrastructure/x.dart';
import 'dart:convert';
import 'package:photohunt_shared/photohunt_shared.dart';
import 'package:uuid/uuid_value.dart';
import '../exceptions.dart';
'''),
        isEmpty,
      );
      expect(
        _violationsOf(
          'src/infrastructure/database/repositories/orm_shot_repository.dart',
          '''
import 'package:serverpod/serverpod.dart';
import '../../../domain/models/models.dart';
import '../../../generated/protocol.dart';
''',
        ),
        isEmpty,
      );
    });

    test('presentation のうち di だけは infrastructure を参照できる', () {
      const source = "import '../../infrastructure/database/x.dart';";
      expect(
        _violationsOf('src/presentation/di/session.dart', source),
        isEmpty,
      );
      expect(
        _violationsOf('src/presentation/endpoints/shot.dart', source),
        hasLength(1),
      );
    });

    test('diのORM・Sessionへの直接DBアクセスを検出する', () {
      for (final source in [
        'void f(dynamic s) { AnonymousAccount.db.count(s); }',
        'void f(dynamic s) { s.db.transaction((tx) {}); }',
        'void f(dynamic s) { final database = s.db; }',
        'void f(dynamic s) { s..db.count(s); }',
      ]) {
        expect(
          _diDatabaseViolations('src/presentation/di/x.dart', source),
          hasLength(1),
        );
      }
    });

    test('diのfactory・文字列・コメントとinfrastructureのDBアクセスは許可する', () {
      expect(
        _diDatabaseViolations('src/presentation/di/x.dart', '''
// AnonymousAccount.db.count(session);
const explanation = 'session.db';
Object factory(dynamic session) => UseCase(OrmRepository(session));
'''),
        isEmpty,
      );
      expect(
        _diDatabaseViolations(
          'src/infrastructure/x.dart',
          'void f(dynamic s) { s.db.transaction((tx) {}); }',
        ),
        isEmpty,
      );
    });
  });

  test('lib/src のファイルが依存方向の規則を守っている', () {
    final files = Directory('lib/src')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .map((f) => f.path.substring('lib/'.length))
        .where((path) => !path.startsWith('src/generated/'))
        .toList();

    // パスを誤って検査対象が空になり、素通りすることを防ぐ。
    for (final layer in ['domain', 'infrastructure', 'presentation']) {
      expect(
        files.where((path) => path.startsWith('src/$layer/')),
        isNotEmpty,
        reason: 'lib/src/$layer のファイルを読めていない',
      );
    }

    final violations = [
      for (final path in files) ...[
        ..._violationsOf(path, File('lib/$path').readAsStringSync()),
        ..._diDatabaseViolations(path, File('lib/$path').readAsStringSync()),
      ],
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}

/// DIは実装の生成までを担当する。DBへの直接参照はASTで検出する。
/// 業務判断すべての検出はできないので、責務のレビューも併用する。
List<String> _diDatabaseViolations(String path, String source) {
  if (!path.startsWith('src/presentation/di/')) return [];
  final visitor = _DiDatabaseVisitor();
  parseString(content: source).unit.accept(visitor);
  return [
    for (final offset in visitor.offsets)
      'lib/$path:$offset: DIからdbへ直接アクセスせずrepository/portの実装へ置く',
  ];
}

class _DiDatabaseVisitor() extends RecursiveAstVisitor<void> {
  final offsets = <int>[];

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final parent = node.parent;
    if (node.name == 'db' &&
        ((parent is PrefixedIdentifier && parent.identifier == node) ||
            (parent is PropertyAccess && parent.propertyName == node))) {
      offsets.add(node.offset);
    }
    super.visitSimpleIdentifier(node);
  }
}

/// 依存方向の規則。[from] 配下のファイルは [denied] で始まる URI を参照しない。
/// [exempt] 配下のファイルはこの規則の対象外。
class const _Rule({
  required final String from,
  required final List<String> denied,
  final List<String> exempt = const [],
});

const _self = 'package:photohunt_server/src';
const _serverpod = ['package:serverpod/', 'package:serverpod_'];

const _rules = [
  _Rule(
    from: 'src/domain/',
    denied: [
      '$_self/application/',
      '$_self/infrastructure/',
      '$_self/presentation/',
      '$_self/generated/',
      ..._serverpod,
    ],
  ),
  _Rule(
    from: 'src/application/',
    denied: [
      '$_self/infrastructure/',
      '$_self/presentation/',
      '$_self/generated/',
      ..._serverpod,
    ],
  ),
  _Rule(from: 'src/infrastructure/', denied: ['$_self/presentation/']),
  _Rule(
    from: 'src/presentation/',
    exempt: ['src/presentation/di/'],
    denied: ['$_self/infrastructure/'],
  ),
];

/// `lib/` からの相対パス [path] にある [source] の違反を、説明文の一覧で返す。
List<String> _violationsOf(String path, String source) {
  final rules = _rules.where(
    (rule) =>
        path.startsWith(rule.from) &&
        !rule.exempt.any((prefix) => path.startsWith(prefix)),
  );
  final library = Uri.parse('package:photohunt_server/$path');
  return [
    for (final uri in _referencedUris(source))
      for (final rule in rules)
        if (uri == null)
          'lib/$path: 静的に解決できない URI がある'
        else if (rule.denied.any(library.resolve(uri).toString().startsWith))
          "lib/$path: '${library.resolve(uri)}' は ${rule.from} から参照できない",
  ];
}

/// import / export / part と、条件付き import の URI を返す。
/// 文字列補間などで値が決まらない URI は null になる。
Iterable<String?> _referencedUris(String source) sync* {
  for (final directive in parseString(content: source).unit.directives) {
    if (directive is UriBasedDirective) {
      yield directive.uri.stringValue;
    }
    if (directive is NamespaceDirective) {
      for (final configuration in directive.configurations) {
        yield configuration.uri.stringValue;
      }
    }
  }
}
