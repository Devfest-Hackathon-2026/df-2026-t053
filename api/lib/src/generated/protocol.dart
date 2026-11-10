/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:photohunt_shared/photohunt_shared.dart' as _ix5zeh3i;
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;

import 'infrastructure/database/tables/asset.dart' as _iuhkvmgv;
import 'infrastructure/database/tables/best_score.dart' as _ikq6a823;
import 'infrastructure/database/tables/challenge.dart' as _ipcblqvm;
import 'infrastructure/database/tables/challenge_revision.dart' as _iv7gfjtc;
import 'infrastructure/database/tables/credit.dart' as _i1zhrgsa;
import 'infrastructure/database/tables/landmark.dart' as _iaep75rf;
import 'infrastructure/database/tables/mode_config.dart' as _i1wiyd9y;
import 'infrastructure/database/tables/pavilion.dart' as _iqh3e9bz;
import 'infrastructure/database/tables/play_session.dart' as _iox60q2h;
import 'infrastructure/database/tables/shot.dart' as _igh6sccs;
import 'infrastructure/database/tables/spawn_point.dart' as _ikiy7nig;
import 'infrastructure/database/tables/structure.dart' as _ig4ozgfs;
import 'infrastructure/database/tables/structure_source.dart' as _ibntegby;
import 'infrastructure/database/tables/user_profile.dart' as _igdznciy;
import 'infrastructure/seed/input/seed_asset_file_input.dart' as _ishf6i2n;
import 'infrastructure/seed/input/seed_assets_input.dart' as _ifk09mcf;
import 'infrastructure/seed/input/seed_challenge_input.dart' as _im6qw8nc;
import 'infrastructure/seed/input/seed_goal_input.dart' as _i2c0eyyk;
import 'infrastructure/seed/input/seed_landmark_input.dart' as _ilh84si0;
import 'infrastructure/seed/input/seed_map_input.dart' as _ibxq0kx5;
import 'infrastructure/seed/input/seed_mode_input.dart' as _ihtnux6q;
import 'infrastructure/seed/input/seed_pavilion_input.dart' as _i2jj1lgr;
import 'infrastructure/seed/input/seed_pavilion_list.dart' as _ie20j1gm;
import 'infrastructure/seed/input/seed_revision_fields.dart' as _ipm20cdw;
import 'infrastructure/seed/input/seed_revision_input.dart' as _ias2iq91;
import 'infrastructure/seed/input/seed_spawn_input.dart' as _i7nco3ro;
import 'infrastructure/seed/input/seed_structure_input.dart' as _iu0cxkgr;
export 'infrastructure/database/tables/asset.dart';
export 'infrastructure/database/tables/best_score.dart';
export 'infrastructure/database/tables/challenge.dart';
export 'infrastructure/database/tables/challenge_revision.dart';
export 'infrastructure/database/tables/credit.dart';
export 'infrastructure/database/tables/landmark.dart';
export 'infrastructure/database/tables/mode_config.dart';
export 'infrastructure/database/tables/pavilion.dart';
export 'infrastructure/database/tables/play_session.dart';
export 'infrastructure/database/tables/shot.dart';
export 'infrastructure/database/tables/spawn_point.dart';
export 'infrastructure/database/tables/structure.dart';
export 'infrastructure/database/tables/structure_source.dart';
export 'infrastructure/database/tables/user_profile.dart';
export 'infrastructure/seed/input/seed_asset_file_input.dart';
export 'infrastructure/seed/input/seed_assets_input.dart';
export 'infrastructure/seed/input/seed_challenge_input.dart';
export 'infrastructure/seed/input/seed_goal_input.dart';
export 'infrastructure/seed/input/seed_landmark_input.dart';
export 'infrastructure/seed/input/seed_map_input.dart';
export 'infrastructure/seed/input/seed_mode_input.dart';
export 'infrastructure/seed/input/seed_pavilion_input.dart';
export 'infrastructure/seed/input/seed_pavilion_list.dart';
export 'infrastructure/seed/input/seed_revision_fields.dart';
export 'infrastructure/seed/input/seed_revision_input.dart';
export 'infrastructure/seed/input/seed_spawn_input.dart';
export 'infrastructure/seed/input/seed_structure_input.dart';

class Protocol extends _is.DatabaseSerializationManager
    implements _is.DatabaseProtocolDeserializationProvider {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  @override
  _is.ProtocolDeserialization get deserializationMetadata =>
      _is.ProtocolDeserialization.cached(
        this,
        types: const [
          _is.getType<_iuhkvmgv.AssetRow>,
          _is.getType<_ikq6a823.BestScoreRow>,
          _is.getType<_ipcblqvm.ChallengeRow>,
          _is.getType<_iv7gfjtc.ChallengeRevisionRow>,
          _is.getType<_i1zhrgsa.CreditRow>,
          _is.getType<_iaep75rf.LandmarkRow>,
          _is.getType<_i1wiyd9y.ModeConfigRow>,
          _is.getType<_iqh3e9bz.PavilionRow>,
          _is.getType<_iox60q2h.PlaySessionRow>,
          _is.getType<_igh6sccs.ShotRow>,
          _is.getType<_ikiy7nig.SpawnPointRow>,
          _is.getType<_ig4ozgfs.StructureRow>,
          _is.getType<_ibntegby.StructureSourceRow>,
          _is.getType<_igdznciy.UserProfileRow>,
          _is.getType<_ishf6i2n.SeedAssetFileInput>,
          _is.getType<_ifk09mcf.SeedAssetsInput>,
          _is.getType<_im6qw8nc.SeedChallengeInput>,
          _is.getType<_i2c0eyyk.SeedGoalInput>,
          _is.getType<_ilh84si0.SeedLandmarkInput>,
          _is.getType<_ibxq0kx5.SeedMapInput>,
          _is.getType<_ihtnux6q.SeedModeInput>,
          _is.getType<_i2jj1lgr.SeedPavilionInput>,
          _is.getType<_ie20j1gm.SeedPavilionList>,
          _is.getType<_ipm20cdw.SeedRevisionFields>,
          _is.getType<_ias2iq91.SeedRevisionInput>,
          _is.getType<_i7nco3ro.SeedSpawnInput>,
          _is.getType<_iu0cxkgr.SeedStructureInput>,
          _is.getType<_iuhkvmgv.AssetRow?>,
          _is.getType<_ikq6a823.BestScoreRow?>,
          _is.getType<_ipcblqvm.ChallengeRow?>,
          _is.getType<_iv7gfjtc.ChallengeRevisionRow?>,
          _is.getType<_i1zhrgsa.CreditRow?>,
          _is.getType<_iaep75rf.LandmarkRow?>,
          _is.getType<_i1wiyd9y.ModeConfigRow?>,
          _is.getType<_iqh3e9bz.PavilionRow?>,
          _is.getType<_iox60q2h.PlaySessionRow?>,
          _is.getType<_igh6sccs.ShotRow?>,
          _is.getType<_ikiy7nig.SpawnPointRow?>,
          _is.getType<_ig4ozgfs.StructureRow?>,
          _is.getType<_ibntegby.StructureSourceRow?>,
          _is.getType<_igdznciy.UserProfileRow?>,
          _is.getType<_ishf6i2n.SeedAssetFileInput?>,
          _is.getType<_ifk09mcf.SeedAssetsInput?>,
          _is.getType<_im6qw8nc.SeedChallengeInput?>,
          _is.getType<_i2c0eyyk.SeedGoalInput?>,
          _is.getType<_ilh84si0.SeedLandmarkInput?>,
          _is.getType<_ibxq0kx5.SeedMapInput?>,
          _is.getType<_ihtnux6q.SeedModeInput?>,
          _is.getType<_i2jj1lgr.SeedPavilionInput?>,
          _is.getType<_ie20j1gm.SeedPavilionList?>,
          _is.getType<_ipm20cdw.SeedRevisionFields?>,
          _is.getType<_ias2iq91.SeedRevisionInput?>,
          _is.getType<_i7nco3ro.SeedSpawnInput?>,
          _is.getType<_iu0cxkgr.SeedStructureInput?>,
          _is.getType<List<_i7nco3ro.SeedSpawnInput>>,
          _is.getType<List<_i2jj1lgr.SeedPavilionInput>>,
          _is.getType<List<_ihtnux6q.SeedModeInput>>,
          _is.getType<List<_ilh84si0.SeedLandmarkInput>>,
          _is.getType<List<_ix5zeh3i.Credit>>,
          _is.getType<List<_iu0cxkgr.SeedStructureInput>>,
          _is.getType<List<_ix5zeh3i.GuideSource>>,
        ],
        modules: const [
          _iais.Protocol.new,
          _iacs.Protocol.new,
          _ix5zeh3i.Protocol.new,
          _isp.Protocol.new,
        ],
        classNames: const [
          'AssetRow',
          'BestScoreRow',
          'ChallengeRow',
          'ChallengeRevisionRow',
          'CreditRow',
          'LandmarkRow',
          'ModeConfigRow',
          'PavilionRow',
          'PlaySessionRow',
          'ShotRow',
          'SpawnPointRow',
          'StructureRow',
          'StructureSourceRow',
          'UserProfileRow',
          'SeedAssetFileInput',
          'SeedAssetsInput',
          'SeedChallengeInput',
          'SeedGoalInput',
          'SeedLandmarkInput',
          'SeedMapInput',
          'SeedModeInput',
          'SeedPavilionInput',
          'SeedPavilionList',
          'SeedRevisionFields',
          'SeedRevisionInput',
          'SeedSpawnInput',
          'SeedStructureInput',
        ],
      );

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'asset',
      dartName: 'AssetRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'sha256',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'object_path',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'content_type',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'byte_length',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'asset_sha256_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sha256',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'best_score',
      dartName: 'BestScoreRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'user_profile_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'mode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'photohunt_shared:PlayMode',
        ),
        _isp.ColumnDefinition(
          name: 'shot_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'score',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'achieved_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'best_score_fk_0',
          columns: ['user_profile_id'],
          referenceTable: 'user_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'best_score_fk_1',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'best_score_fk_2',
          columns: ['shot_id'],
          referenceTable: 'shot',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'best_score_profile_revision_mode_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'user_profile_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'mode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'best_score_shot_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'shot_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _isp.IndexDefinition(
          indexName: 'best_score_ranking_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'mode',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'score',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'achieved_at',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'user_profile_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'challenge',
      dartName: 'ChallengeRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'slug',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'current_revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'challenge_fk_0',
          columns: ['current_revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'challenge_slug_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'slug',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'challenge_revision',
      dartName: 'ChallengeRevisionRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'challenge_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'revision_no',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'scene_profile',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'scoring_version',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'photo_asset_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'map_asset_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'photo_alt',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'map_bounds_xz',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'eye_height_m',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'shot_fov_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'goal_x',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'goal_y',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'goal_z',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'goal_yaw_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'goal_pitch_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'story',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'highlight',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'published_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'seed_digest',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'challenge_revision_fk_0',
          columns: ['challenge_id'],
          referenceTable: 'challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'challenge_revision_fk_1',
          columns: ['photo_asset_id'],
          referenceTable: 'asset',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'challenge_revision_fk_2',
          columns: ['map_asset_id'],
          referenceTable: 'asset',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'challenge_revision_challenge_no_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'challenge_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_no',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'credit',
      dartName: 'CreditRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'url',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'credit_fk_0',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'credit_revision_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sort_order',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'landmark',
      dartName: 'LandmarkRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'pavilion_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'display_name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'pos_x',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'pos_z',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'lat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'lon',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'landmark_fk_0',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'landmark_fk_1',
          columns: ['pavilion_id'],
          referenceTable: 'pavilion',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'landmark_revision_pavilion_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'pavilion_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'mode_config',
      dartName: 'ModeConfigRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'mode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'photohunt_shared:PlayMode',
        ),
        _isp.ColumnDefinition(
          name: 'walkable',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'mode_config_fk_0',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'mode_config_revision_mode_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'mode',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'pavilion',
      dartName: 'PavilionRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'source_key',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'lat',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
        _isp.ColumnDefinition(
          name: 'lon',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: true,
          dartType: 'double?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'pavilion_source_key_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'source_key',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'play_session',
      dartName: 'PlaySessionRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'random_v7',
        ),
        _isp.ColumnDefinition(
          name: 'request_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'mode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'photohunt_shared:PlayMode',
        ),
        _isp.ColumnDefinition(
          name: 'spawn_point_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'user_profile_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'started_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'expires_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'play_session_fk_0',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'play_session_fk_1',
          columns: ['spawn_point_id'],
          referenceTable: 'spawn_point',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'play_session_fk_2',
          columns: ['user_profile_id'],
          referenceTable: 'user_profile',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'play_session_profile_request_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'user_profile_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'request_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'shot',
      dartName: 'ShotRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'request_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'play_session_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'x',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'y',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'z',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'yaw_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'pitch_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'fov_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'distance_m',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'yaw_diff_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'pitch_diff_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'score',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'rank_at_submission',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'best_score_at_submission',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'nickname_at_submission',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'best_achieve_time_at_submission',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'shot_fk_0',
          columns: ['play_session_id'],
          referenceTable: 'play_session',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'shot_play_session_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'play_session_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'spawn_point',
      dartName: 'SpawnPointRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'mode_config_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'x',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'y',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'z',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'yaw_deg',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'label',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'spawn_point_fk_0',
          columns: ['mode_config_id'],
          referenceTable: 'mode_config',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'spawn_point_mode_config_order_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'mode_config_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sort_order',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'structure',
      dartName: 'StructureRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'revision_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'pavilion_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: true,
          dartType: 'int?',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'pos_x',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'pos_z',
          columnType: _isp.ColumnType.doublePrecision,
          isNullable: false,
          dartType: 'double',
        ),
        _isp.ColumnDefinition(
          name: 'facts',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'fallback_text',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'structure_fk_0',
          columns: ['revision_id'],
          referenceTable: 'challenge_revision',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'structure_fk_1',
          columns: ['pavilion_id'],
          referenceTable: 'pavilion',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.restrict,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'structure_revision_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'revision_id',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'structure_source',
      dartName: 'StructureSourceRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'structure_id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'title',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'url',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'sort_order',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'structure_source_fk_0',
          columns: ['structure_id'],
          referenceTable: 'structure',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'structure_source_structure_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'structure_id',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'sort_order',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'user_profile',
      dartName: 'UserProfileRow',
      schema: 'public',
      module: 'photohunt',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'auth_user_id',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'nickname',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'created_at',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'user_profile_auth_user_uk',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'auth_user_id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._ix5zeh3i.Protocol() is _is.DatabaseSerializationManager
        ? (_ix5zeh3i.Protocol() as _is.DatabaseSerializationManager)
              .getTargetTableDefinitions()
        : [],
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) =>
      _is.ProtocolDeserialization.readClassName(data);

  @override
  T deserialize<T>(dynamic data, [Type? t]) {
    t ??= T;
    final rawDataClassName = _is.ProtocolDeserialization.readClassName(data);
    final dataClassName = rawDataClassName;
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _iuhkvmgv.AssetRow) {
      return _iuhkvmgv.AssetRow.fromJson(data) as T;
    }
    if (t == _ikq6a823.BestScoreRow) {
      return _ikq6a823.BestScoreRow.fromJson(data) as T;
    }
    if (t == _ipcblqvm.ChallengeRow) {
      return _ipcblqvm.ChallengeRow.fromJson(data) as T;
    }
    if (t == _iv7gfjtc.ChallengeRevisionRow) {
      return _iv7gfjtc.ChallengeRevisionRow.fromJson(data) as T;
    }
    if (t == _i1zhrgsa.CreditRow) {
      return _i1zhrgsa.CreditRow.fromJson(data) as T;
    }
    if (t == _iaep75rf.LandmarkRow) {
      return _iaep75rf.LandmarkRow.fromJson(data) as T;
    }
    if (t == _i1wiyd9y.ModeConfigRow) {
      return _i1wiyd9y.ModeConfigRow.fromJson(data) as T;
    }
    if (t == _iqh3e9bz.PavilionRow) {
      return _iqh3e9bz.PavilionRow.fromJson(data) as T;
    }
    if (t == _iox60q2h.PlaySessionRow) {
      return _iox60q2h.PlaySessionRow.fromJson(data) as T;
    }
    if (t == _igh6sccs.ShotRow) {
      return _igh6sccs.ShotRow.fromJson(data) as T;
    }
    if (t == _ikiy7nig.SpawnPointRow) {
      return _ikiy7nig.SpawnPointRow.fromJson(data) as T;
    }
    if (t == _ig4ozgfs.StructureRow) {
      return _ig4ozgfs.StructureRow.fromJson(data) as T;
    }
    if (t == _ibntegby.StructureSourceRow) {
      return _ibntegby.StructureSourceRow.fromJson(data) as T;
    }
    if (t == _igdznciy.UserProfileRow) {
      return _igdznciy.UserProfileRow.fromJson(data) as T;
    }
    if (t == _ishf6i2n.SeedAssetFileInput) {
      return _ishf6i2n.SeedAssetFileInput.fromJson(data) as T;
    }
    if (t == _ifk09mcf.SeedAssetsInput) {
      return _ifk09mcf.SeedAssetsInput.fromJson(data) as T;
    }
    if (t == _im6qw8nc.SeedChallengeInput) {
      return _im6qw8nc.SeedChallengeInput.fromJson(data) as T;
    }
    if (t == _i2c0eyyk.SeedGoalInput) {
      return _i2c0eyyk.SeedGoalInput.fromJson(data) as T;
    }
    if (t == _ilh84si0.SeedLandmarkInput) {
      return _ilh84si0.SeedLandmarkInput.fromJson(data) as T;
    }
    if (t == _ibxq0kx5.SeedMapInput) {
      return _ibxq0kx5.SeedMapInput.fromJson(data) as T;
    }
    if (t == _ihtnux6q.SeedModeInput) {
      return _ihtnux6q.SeedModeInput.fromJson(data) as T;
    }
    if (t == _i2jj1lgr.SeedPavilionInput) {
      return _i2jj1lgr.SeedPavilionInput.fromJson(data) as T;
    }
    if (t == _ie20j1gm.SeedPavilionList) {
      return _ie20j1gm.SeedPavilionList.fromJson(data) as T;
    }
    if (t == _ipm20cdw.SeedRevisionFields) {
      return _ipm20cdw.SeedRevisionFields.fromJson(data) as T;
    }
    if (t == _ias2iq91.SeedRevisionInput) {
      return _ias2iq91.SeedRevisionInput.fromJson(data) as T;
    }
    if (t == _i7nco3ro.SeedSpawnInput) {
      return _i7nco3ro.SeedSpawnInput.fromJson(data) as T;
    }
    if (t == _iu0cxkgr.SeedStructureInput) {
      return _iu0cxkgr.SeedStructureInput.fromJson(data) as T;
    }
    if (t == _is.getType<_iuhkvmgv.AssetRow?>()) {
      return (data != null ? _iuhkvmgv.AssetRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikq6a823.BestScoreRow?>()) {
      return (data != null ? _ikq6a823.BestScoreRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ipcblqvm.ChallengeRow?>()) {
      return (data != null ? _ipcblqvm.ChallengeRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iv7gfjtc.ChallengeRevisionRow?>()) {
      return (data != null
              ? _iv7gfjtc.ChallengeRevisionRow.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_i1zhrgsa.CreditRow?>()) {
      return (data != null ? _i1zhrgsa.CreditRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iaep75rf.LandmarkRow?>()) {
      return (data != null ? _iaep75rf.LandmarkRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_i1wiyd9y.ModeConfigRow?>()) {
      return (data != null ? _i1wiyd9y.ModeConfigRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iqh3e9bz.PavilionRow?>()) {
      return (data != null ? _iqh3e9bz.PavilionRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iox60q2h.PlaySessionRow?>()) {
      return (data != null ? _iox60q2h.PlaySessionRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igh6sccs.ShotRow?>()) {
      return (data != null ? _igh6sccs.ShotRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ikiy7nig.SpawnPointRow?>()) {
      return (data != null ? _ikiy7nig.SpawnPointRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ig4ozgfs.StructureRow?>()) {
      return (data != null ? _ig4ozgfs.StructureRow.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ibntegby.StructureSourceRow?>()) {
      return (data != null ? _ibntegby.StructureSourceRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_igdznciy.UserProfileRow?>()) {
      return (data != null ? _igdznciy.UserProfileRow.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ishf6i2n.SeedAssetFileInput?>()) {
      return (data != null ? _ishf6i2n.SeedAssetFileInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ifk09mcf.SeedAssetsInput?>()) {
      return (data != null ? _ifk09mcf.SeedAssetsInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_im6qw8nc.SeedChallengeInput?>()) {
      return (data != null ? _im6qw8nc.SeedChallengeInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2c0eyyk.SeedGoalInput?>()) {
      return (data != null ? _i2c0eyyk.SeedGoalInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilh84si0.SeedLandmarkInput?>()) {
      return (data != null ? _ilh84si0.SeedLandmarkInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ibxq0kx5.SeedMapInput?>()) {
      return (data != null ? _ibxq0kx5.SeedMapInput.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ihtnux6q.SeedModeInput?>()) {
      return (data != null ? _ihtnux6q.SeedModeInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i2jj1lgr.SeedPavilionInput?>()) {
      return (data != null ? _i2jj1lgr.SeedPavilionInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ie20j1gm.SeedPavilionList?>()) {
      return (data != null ? _ie20j1gm.SeedPavilionList.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ipm20cdw.SeedRevisionFields?>()) {
      return (data != null ? _ipm20cdw.SeedRevisionFields.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ias2iq91.SeedRevisionInput?>()) {
      return (data != null ? _ias2iq91.SeedRevisionInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i7nco3ro.SeedSpawnInput?>()) {
      return (data != null ? _i7nco3ro.SeedSpawnInput.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iu0cxkgr.SeedStructureInput?>()) {
      return (data != null ? _iu0cxkgr.SeedStructureInput.fromJson(data) : null)
          as T;
    }
    if (t == List<_i7nco3ro.SeedSpawnInput>) {
      return (data as List)
              .map((e) => deserialize<_i7nco3ro.SeedSpawnInput>(e))
              .toList()
          as T;
    }
    if (t == List<_i2jj1lgr.SeedPavilionInput>) {
      return (data as List)
              .map((e) => deserialize<_i2jj1lgr.SeedPavilionInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ihtnux6q.SeedModeInput>) {
      return (data as List)
              .map((e) => deserialize<_ihtnux6q.SeedModeInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ilh84si0.SeedLandmarkInput>) {
      return (data as List)
              .map((e) => deserialize<_ilh84si0.SeedLandmarkInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.Credit>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.Credit>(e))
              .toList()
          as T;
    }
    if (t == List<_iu0cxkgr.SeedStructureInput>) {
      return (data as List)
              .map((e) => deserialize<_iu0cxkgr.SeedStructureInput>(e))
              .toList()
          as T;
    }
    if (t == List<_ix5zeh3i.GuideSource>) {
      return (data as List)
              .map((e) => deserialize<_ix5zeh3i.GuideSource>(e))
              .toList()
          as T;
    }
    final modules = deserializationMetadata.modulesForDeserialization(
      t,
      className: rawDataClassName,
    );
    for (final module in modules) {
      try {
        return module.deserialize<T>(data, t);
      } on _is.DeserializationTypeNotFoundException catch (_) {}
    }

    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _iuhkvmgv.AssetRow => 'AssetRow',
      _ikq6a823.BestScoreRow => 'BestScoreRow',
      _ipcblqvm.ChallengeRow => 'ChallengeRow',
      _iv7gfjtc.ChallengeRevisionRow => 'ChallengeRevisionRow',
      _i1zhrgsa.CreditRow => 'CreditRow',
      _iaep75rf.LandmarkRow => 'LandmarkRow',
      _i1wiyd9y.ModeConfigRow => 'ModeConfigRow',
      _iqh3e9bz.PavilionRow => 'PavilionRow',
      _iox60q2h.PlaySessionRow => 'PlaySessionRow',
      _igh6sccs.ShotRow => 'ShotRow',
      _ikiy7nig.SpawnPointRow => 'SpawnPointRow',
      _ig4ozgfs.StructureRow => 'StructureRow',
      _ibntegby.StructureSourceRow => 'StructureSourceRow',
      _igdznciy.UserProfileRow => 'UserProfileRow',
      _ishf6i2n.SeedAssetFileInput => 'SeedAssetFileInput',
      _ifk09mcf.SeedAssetsInput => 'SeedAssetsInput',
      _im6qw8nc.SeedChallengeInput => 'SeedChallengeInput',
      _i2c0eyyk.SeedGoalInput => 'SeedGoalInput',
      _ilh84si0.SeedLandmarkInput => 'SeedLandmarkInput',
      _ibxq0kx5.SeedMapInput => 'SeedMapInput',
      _ihtnux6q.SeedModeInput => 'SeedModeInput',
      _i2jj1lgr.SeedPavilionInput => 'SeedPavilionInput',
      _ie20j1gm.SeedPavilionList => 'SeedPavilionList',
      _ipm20cdw.SeedRevisionFields => 'SeedRevisionFields',
      _ias2iq91.SeedRevisionInput => 'SeedRevisionInput',
      _i7nco3ro.SeedSpawnInput => 'SeedSpawnInput',
      _iu0cxkgr.SeedStructureInput => 'SeedStructureInput',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('photohunt.', '');
    }

    switch (data) {
      case _iuhkvmgv.AssetRow():
        return 'AssetRow';
      case _ikq6a823.BestScoreRow():
        return 'BestScoreRow';
      case _ipcblqvm.ChallengeRow():
        return 'ChallengeRow';
      case _iv7gfjtc.ChallengeRevisionRow():
        return 'ChallengeRevisionRow';
      case _i1zhrgsa.CreditRow():
        return 'CreditRow';
      case _iaep75rf.LandmarkRow():
        return 'LandmarkRow';
      case _i1wiyd9y.ModeConfigRow():
        return 'ModeConfigRow';
      case _iqh3e9bz.PavilionRow():
        return 'PavilionRow';
      case _iox60q2h.PlaySessionRow():
        return 'PlaySessionRow';
      case _igh6sccs.ShotRow():
        return 'ShotRow';
      case _ikiy7nig.SpawnPointRow():
        return 'SpawnPointRow';
      case _ig4ozgfs.StructureRow():
        return 'StructureRow';
      case _ibntegby.StructureSourceRow():
        return 'StructureSourceRow';
      case _igdznciy.UserProfileRow():
        return 'UserProfileRow';
      case _ishf6i2n.SeedAssetFileInput():
        return 'SeedAssetFileInput';
      case _ifk09mcf.SeedAssetsInput():
        return 'SeedAssetsInput';
      case _im6qw8nc.SeedChallengeInput():
        return 'SeedChallengeInput';
      case _i2c0eyyk.SeedGoalInput():
        return 'SeedGoalInput';
      case _ilh84si0.SeedLandmarkInput():
        return 'SeedLandmarkInput';
      case _ibxq0kx5.SeedMapInput():
        return 'SeedMapInput';
      case _ihtnux6q.SeedModeInput():
        return 'SeedModeInput';
      case _i2jj1lgr.SeedPavilionInput():
        return 'SeedPavilionInput';
      case _ie20j1gm.SeedPavilionList():
        return 'SeedPavilionList';
      case _ipm20cdw.SeedRevisionFields():
        return 'SeedRevisionFields';
      case _ias2iq91.SeedRevisionInput():
        return 'SeedRevisionInput';
      case _i7nco3ro.SeedSpawnInput():
        return 'SeedSpawnInput';
      case _iu0cxkgr.SeedStructureInput():
        return 'SeedStructureInput';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _ix5zeh3i.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'photohunt_shared.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AssetRow') {
      return deserialize<_iuhkvmgv.AssetRow>(data['data']);
    }
    if (dataClassName == 'BestScoreRow') {
      return deserialize<_ikq6a823.BestScoreRow>(data['data']);
    }
    if (dataClassName == 'ChallengeRow') {
      return deserialize<_ipcblqvm.ChallengeRow>(data['data']);
    }
    if (dataClassName == 'ChallengeRevisionRow') {
      return deserialize<_iv7gfjtc.ChallengeRevisionRow>(data['data']);
    }
    if (dataClassName == 'CreditRow') {
      return deserialize<_i1zhrgsa.CreditRow>(data['data']);
    }
    if (dataClassName == 'LandmarkRow') {
      return deserialize<_iaep75rf.LandmarkRow>(data['data']);
    }
    if (dataClassName == 'ModeConfigRow') {
      return deserialize<_i1wiyd9y.ModeConfigRow>(data['data']);
    }
    if (dataClassName == 'PavilionRow') {
      return deserialize<_iqh3e9bz.PavilionRow>(data['data']);
    }
    if (dataClassName == 'PlaySessionRow') {
      return deserialize<_iox60q2h.PlaySessionRow>(data['data']);
    }
    if (dataClassName == 'ShotRow') {
      return deserialize<_igh6sccs.ShotRow>(data['data']);
    }
    if (dataClassName == 'SpawnPointRow') {
      return deserialize<_ikiy7nig.SpawnPointRow>(data['data']);
    }
    if (dataClassName == 'StructureRow') {
      return deserialize<_ig4ozgfs.StructureRow>(data['data']);
    }
    if (dataClassName == 'StructureSourceRow') {
      return deserialize<_ibntegby.StructureSourceRow>(data['data']);
    }
    if (dataClassName == 'UserProfileRow') {
      return deserialize<_igdznciy.UserProfileRow>(data['data']);
    }
    if (dataClassName == 'SeedAssetFileInput') {
      return deserialize<_ishf6i2n.SeedAssetFileInput>(data['data']);
    }
    if (dataClassName == 'SeedAssetsInput') {
      return deserialize<_ifk09mcf.SeedAssetsInput>(data['data']);
    }
    if (dataClassName == 'SeedChallengeInput') {
      return deserialize<_im6qw8nc.SeedChallengeInput>(data['data']);
    }
    if (dataClassName == 'SeedGoalInput') {
      return deserialize<_i2c0eyyk.SeedGoalInput>(data['data']);
    }
    if (dataClassName == 'SeedLandmarkInput') {
      return deserialize<_ilh84si0.SeedLandmarkInput>(data['data']);
    }
    if (dataClassName == 'SeedMapInput') {
      return deserialize<_ibxq0kx5.SeedMapInput>(data['data']);
    }
    if (dataClassName == 'SeedModeInput') {
      return deserialize<_ihtnux6q.SeedModeInput>(data['data']);
    }
    if (dataClassName == 'SeedPavilionInput') {
      return deserialize<_i2jj1lgr.SeedPavilionInput>(data['data']);
    }
    if (dataClassName == 'SeedPavilionList') {
      return deserialize<_ie20j1gm.SeedPavilionList>(data['data']);
    }
    if (dataClassName == 'SeedRevisionFields') {
      return deserialize<_ipm20cdw.SeedRevisionFields>(data['data']);
    }
    if (dataClassName == 'SeedRevisionInput') {
      return deserialize<_ias2iq91.SeedRevisionInput>(data['data']);
    }
    if (dataClassName == 'SeedSpawnInput') {
      return deserialize<_i7nco3ro.SeedSpawnInput>(data['data']);
    }
    if (dataClassName == 'SeedStructureInput') {
      return deserialize<_iu0cxkgr.SeedStructureInput>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      return _iais.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(19),
      });
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      return _iacs.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(20),
      });
    }
    if (dataClassName.startsWith('photohunt_shared.')) {
      return _ix5zeh3i.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(17),
      });
    }
    if (dataClassName.startsWith('serverpod.')) {
      return _isp.Protocol().deserializeByClassName({
        ...data,
        'className': dataClassName.substring(10),
      });
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('photohunt', this);
    _iacs.Protocol().registerHostProtocol('photohunt', this);
    _ix5zeh3i.Protocol().registerHostProtocol('photohunt', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var protocol = _ix5zeh3i.Protocol();
      var table = protocol is _is.DatabaseSerializationManager
          ? (protocol as _is.DatabaseSerializationManager).getTableForType(t)
          : null;
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _iuhkvmgv.AssetRow:
        return _iuhkvmgv.AssetRow.t;
      case _ikq6a823.BestScoreRow:
        return _ikq6a823.BestScoreRow.t;
      case _ipcblqvm.ChallengeRow:
        return _ipcblqvm.ChallengeRow.t;
      case _iv7gfjtc.ChallengeRevisionRow:
        return _iv7gfjtc.ChallengeRevisionRow.t;
      case _i1zhrgsa.CreditRow:
        return _i1zhrgsa.CreditRow.t;
      case _iaep75rf.LandmarkRow:
        return _iaep75rf.LandmarkRow.t;
      case _i1wiyd9y.ModeConfigRow:
        return _i1wiyd9y.ModeConfigRow.t;
      case _iqh3e9bz.PavilionRow:
        return _iqh3e9bz.PavilionRow.t;
      case _iox60q2h.PlaySessionRow:
        return _iox60q2h.PlaySessionRow.t;
      case _igh6sccs.ShotRow:
        return _igh6sccs.ShotRow.t;
      case _ikiy7nig.SpawnPointRow:
        return _ikiy7nig.SpawnPointRow.t;
      case _ig4ozgfs.StructureRow:
        return _ig4ozgfs.StructureRow.t;
      case _ibntegby.StructureSourceRow:
        return _ibntegby.StructureSourceRow.t;
      case _igdznciy.UserProfileRow:
        return _igdznciy.UserProfileRow.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'photohunt';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
