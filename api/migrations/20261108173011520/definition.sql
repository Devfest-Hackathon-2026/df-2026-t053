BEGIN;

--
-- 手書きの追記（#22）。Serverpod の .spy.yaml では表現できない制約を足している。
-- 追記したのは次のとおり。create-migration はこのファイルを作り直さないので消えないが、
-- テーブルを作り直す migration を足すときは、同じ制約を引き継ぐこと。
--   asset: sha256 の形式（小文字の16進64桁）と byte_length > 0 の CHECK
--   shot: score の範囲（0〜1000）の CHECK、更新禁止のトリガー
--   mode_config.walkable / challenge_revision.map_bounds_xz: json_valid の CHECK
--   best_score_ranking_idx: score DESC, achieved_at ASC, user_profile_id ASC
--

--
-- Class AssetRow as table asset
--
CREATE TABLE "asset" (
    "id" INTEGER PRIMARY KEY,
    "sha256" TEXT NOT NULL,
    "object_path" TEXT NOT NULL,
    "content_type" TEXT NOT NULL,
    "byte_length" INTEGER NOT NULL,
    "created_at" INTEGER NOT NULL,
    CONSTRAINT "asset_sha256_format_ck" CHECK (length("sha256") = 64 AND "sha256" NOT GLOB '*[^0-9a-f]*'),
    CONSTRAINT "asset_byte_length_ck" CHECK ("byte_length" > 0)
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "asset_sha256_uk" ON "asset" ("sha256");


--
-- Class BestScoreRow as table best_score
--
CREATE TABLE "best_score" (
    "id" INTEGER PRIMARY KEY,
    "user_profile_id" INTEGER NOT NULL,
    "revision_id" INTEGER NOT NULL,
    "mode" TEXT NOT NULL,
    "shot_id" INTEGER NOT NULL,
    "score" INTEGER NOT NULL,
    "achieved_at" INTEGER NOT NULL,
    CONSTRAINT "best_score_fk_0" FOREIGN KEY ("user_profile_id") REFERENCES "user_profile" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "best_score_fk_1" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "best_score_fk_2" FOREIGN KEY ("shot_id") REFERENCES "shot" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "best_score_profile_revision_mode_uk" ON "best_score" ("user_profile_id", "revision_id", "mode");
CREATE UNIQUE INDEX "best_score_shot_uk" ON "best_score" ("shot_id");
CREATE INDEX "best_score_ranking_idx" ON "best_score" ("revision_id", "mode", "score" DESC, "achieved_at" ASC, "user_profile_id" ASC);


--
-- Class ChallengeRow as table challenge
--
CREATE TABLE "challenge" (
    "id" INTEGER PRIMARY KEY,
    "slug" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "current_revision_id" INTEGER,
    "created_at" INTEGER NOT NULL,
    CONSTRAINT "challenge_fk_0" FOREIGN KEY ("current_revision_id") REFERENCES "challenge_revision" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "challenge_slug_uk" ON "challenge" ("slug");


--
-- Class ChallengeRevisionRow as table challenge_revision
--
CREATE TABLE "challenge_revision" (
    "id" INTEGER PRIMARY KEY,
    "challenge_id" INTEGER NOT NULL,
    "revision_no" INTEGER NOT NULL,
    "scene_profile" TEXT NOT NULL,
    "scoring_version" TEXT NOT NULL,
    "photo_asset_id" INTEGER NOT NULL,
    "map_asset_id" INTEGER NOT NULL,
    "photo_alt" TEXT NOT NULL,
    "map_bounds_xz" TEXT NOT NULL,
    "eye_height_m" REAL NOT NULL,
    "shot_fov_deg" REAL NOT NULL,
    "goal_x" REAL NOT NULL,
    "goal_y" REAL NOT NULL,
    "goal_z" REAL NOT NULL,
    "goal_yaw_deg" REAL NOT NULL,
    "goal_pitch_deg" REAL NOT NULL,
    "story" TEXT NOT NULL,
    "highlight" TEXT NOT NULL,
    "published_at" INTEGER,
    "created_at" INTEGER NOT NULL,
    CONSTRAINT "challenge_revision_map_bounds_json_ck" CHECK (json_valid("map_bounds_xz")),
    CONSTRAINT "challenge_revision_fk_0" FOREIGN KEY ("challenge_id") REFERENCES "challenge" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "challenge_revision_fk_1" FOREIGN KEY ("photo_asset_id") REFERENCES "asset" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "challenge_revision_fk_2" FOREIGN KEY ("map_asset_id") REFERENCES "asset" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "challenge_revision_challenge_no_uk" ON "challenge_revision" ("challenge_id", "revision_no");


--
-- Class CreditRow as table credit
--
CREATE TABLE "credit" (
    "id" INTEGER PRIMARY KEY,
    "revision_id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "url" TEXT,
    "sort_order" INTEGER NOT NULL,
    CONSTRAINT "credit_fk_0" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "credit_revision_idx" ON "credit" ("revision_id", "sort_order");


--
-- Class LandmarkRow as table landmark
--
CREATE TABLE "landmark" (
    "id" INTEGER PRIMARY KEY,
    "revision_id" INTEGER NOT NULL,
    "pavilion_id" INTEGER NOT NULL,
    "display_name" TEXT NOT NULL,
    "pos_x" REAL NOT NULL,
    "pos_z" REAL NOT NULL,
    "lat" REAL,
    "lon" REAL,
    CONSTRAINT "landmark_fk_0" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "landmark_fk_1" FOREIGN KEY ("pavilion_id") REFERENCES "pavilion" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "landmark_revision_pavilion_uk" ON "landmark" ("revision_id", "pavilion_id");


--
-- Class ModeConfigRow as table mode_config
--
CREATE TABLE "mode_config" (
    "id" INTEGER PRIMARY KEY,
    "revision_id" INTEGER NOT NULL,
    "mode" TEXT NOT NULL,
    "walkable" TEXT NOT NULL,
    CONSTRAINT "mode_config_walkable_json_ck" CHECK (json_valid("walkable")),
    CONSTRAINT "mode_config_fk_0" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "mode_config_revision_mode_uk" ON "mode_config" ("revision_id", "mode");


--
-- Class PavilionRow as table pavilion
--
CREATE TABLE "pavilion" (
    "id" INTEGER PRIMARY KEY,
    "source_key" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "lat" REAL,
    "lon" REAL
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "pavilion_source_key_uk" ON "pavilion" ("source_key");


--
-- Class PlaySessionRow as table play_session
--
CREATE TABLE "play_session" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "request_id" BLOB NOT NULL,
    "revision_id" INTEGER NOT NULL,
    "mode" TEXT NOT NULL,
    "spawn_point_id" INTEGER NOT NULL,
    "user_profile_id" INTEGER NOT NULL,
    "started_at" INTEGER NOT NULL,
    "expires_at" INTEGER NOT NULL,
    CONSTRAINT "play_session_fk_0" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "play_session_fk_1" FOREIGN KEY ("spawn_point_id") REFERENCES "spawn_point" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "play_session_fk_2" FOREIGN KEY ("user_profile_id") REFERENCES "user_profile" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "play_session_profile_request_uk" ON "play_session" ("user_profile_id", "request_id");


--
-- Class ShotRow as table shot
--
CREATE TABLE "shot" (
    "id" INTEGER PRIMARY KEY,
    "request_id" BLOB NOT NULL,
    "play_session_id" BLOB NOT NULL,
    "x" REAL NOT NULL,
    "y" REAL NOT NULL,
    "z" REAL NOT NULL,
    "yaw_deg" REAL NOT NULL,
    "pitch_deg" REAL NOT NULL,
    "fov_deg" REAL NOT NULL,
    "distance_m" REAL NOT NULL,
    "yaw_diff_deg" REAL NOT NULL,
    "pitch_diff_deg" REAL NOT NULL,
    "score" INTEGER NOT NULL,
    "rank_at_submission" INTEGER NOT NULL,
    "best_score_at_submission" INTEGER NOT NULL,
    "nickname_at_submission" TEXT NOT NULL,
    "best_achieve_time_at_submission" INTEGER NOT NULL,
    "created_at" INTEGER NOT NULL,
    CONSTRAINT "shot_score_range_ck" CHECK ("score" BETWEEN 0 AND 1000),
    CONSTRAINT "shot_fk_0" FOREIGN KEY ("play_session_id") REFERENCES "play_session" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "shot_play_session_uk" ON "shot" ("play_session_id");
CREATE TRIGGER "shot_no_update" BEFORE UPDATE ON "shot"
BEGIN
    SELECT RAISE(ABORT, 'shot is immutable');
END;


--
-- Class SpawnPointRow as table spawn_point
--
CREATE TABLE "spawn_point" (
    "id" INTEGER PRIMARY KEY,
    "mode_config_id" INTEGER NOT NULL,
    "x" REAL NOT NULL,
    "y" REAL NOT NULL,
    "z" REAL NOT NULL,
    "yaw_deg" REAL NOT NULL,
    "sort_order" INTEGER NOT NULL,
    CONSTRAINT "spawn_point_fk_0" FOREIGN KEY ("mode_config_id") REFERENCES "mode_config" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "spawn_point_mode_config_order_uk" ON "spawn_point" ("mode_config_id", "sort_order");


--
-- Class StructureRow as table structure
--
CREATE TABLE "structure" (
    "id" INTEGER PRIMARY KEY,
    "revision_id" INTEGER NOT NULL,
    "pavilion_id" INTEGER,
    "name" TEXT NOT NULL,
    "pos_x" REAL NOT NULL,
    "pos_z" REAL NOT NULL,
    "facts" TEXT NOT NULL,
    "fallback_text" TEXT NOT NULL,
    CONSTRAINT "structure_fk_0" FOREIGN KEY ("revision_id") REFERENCES "challenge_revision" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "structure_fk_1" FOREIGN KEY ("pavilion_id") REFERENCES "pavilion" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "structure_revision_idx" ON "structure" ("revision_id");


--
-- Class StructureSourceRow as table structure_source
--
CREATE TABLE "structure_source" (
    "id" INTEGER PRIMARY KEY,
    "structure_id" INTEGER NOT NULL,
    "title" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    "sort_order" INTEGER NOT NULL,
    CONSTRAINT "structure_source_fk_0" FOREIGN KEY ("structure_id") REFERENCES "structure" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "structure_source_structure_idx" ON "structure_source" ("structure_id", "sort_order");


--
-- Class UserProfileRow as table user_profile
--
CREATE TABLE "user_profile" (
    "id" INTEGER PRIMARY KEY,
    "auth_user_id" BLOB NOT NULL,
    "nickname" TEXT NOT NULL,
    "created_at" INTEGER NOT NULL
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "user_profile_auth_user_uk" ON "user_profile" ("auth_user_id");


--
-- Class CloudStorageEntry as table serverpod_cloud_storage
--
CREATE TABLE "serverpod_cloud_storage" (
    "id" INTEGER PRIMARY KEY,
    "storageId" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "addedTime" INTEGER NOT NULL,
    "expiration" INTEGER,
    "byteData" BLOB NOT NULL,
    "verified" INTEGER NOT NULL,
    "contentType" TEXT,
    "cacheControl" TEXT,
    "contentDisposition" TEXT,
    "contentEncoding" TEXT,
    "customMetadata" TEXT
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_path_idx" ON "serverpod_cloud_storage" ("storageId", "path");
CREATE INDEX "serverpod_cloud_storage_expiration" ON "serverpod_cloud_storage" ("expiration");


--
-- Class CloudStorageDirectDownloadEntry as table serverpod_cloud_storage_direct_download
--
CREATE TABLE "serverpod_cloud_storage_direct_download" (
    "id" INTEGER PRIMARY KEY,
    "storageId" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "expiration" INTEGER NOT NULL,
    "authKey" TEXT NOT NULL,
    "downloadFileName" TEXT,
    "contentType" TEXT
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_download_auth_key" ON "serverpod_cloud_storage_direct_download" ("authKey");
CREATE INDEX "serverpod_cloud_storage_direct_download_expiration" ON "serverpod_cloud_storage_direct_download" ("expiration");


--
-- Class CloudStorageDirectUploadEntry as table serverpod_cloud_storage_direct_upload
--
CREATE TABLE "serverpod_cloud_storage_direct_upload" (
    "id" INTEGER PRIMARY KEY,
    "storageId" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "expiration" INTEGER NOT NULL,
    "authKey" TEXT NOT NULL,
    "maxFileSize" INTEGER NOT NULL DEFAULT (10485760),
    "contentLength" INTEGER,
    "preventOverwrite" INTEGER NOT NULL DEFAULT (0),
    "contentType" TEXT,
    "cacheControl" TEXT,
    "contentDisposition" TEXT,
    "contentEncoding" TEXT,
    "customMetadata" TEXT
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_cloud_storage_direct_upload_storage_path" ON "serverpod_cloud_storage_direct_upload" ("storageId", "path");


--
-- Class FutureCallEntry as table serverpod_future_call
--
CREATE TABLE "serverpod_future_call" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "time" INTEGER NOT NULL,
    "serializedObject" TEXT,
    "serverId" TEXT NOT NULL,
    "identifier" TEXT,
    "scheduling" TEXT
) STRICT;

-- Indexes
CREATE INDEX "serverpod_future_call_time_idx" ON "serverpod_future_call" ("time");
CREATE INDEX "serverpod_future_call_serverId_idx" ON "serverpod_future_call" ("serverId");
CREATE INDEX "serverpod_future_call_identifier_idx" ON "serverpod_future_call" ("identifier");


--
-- Class FutureCallClaimEntry as table serverpod_future_call_claim
--
CREATE TABLE "serverpod_future_call_claim" (
    "id" INTEGER PRIMARY KEY,
    "futureCallId" INTEGER,
    "lastHeartbeatTime" INTEGER NOT NULL,
    CONSTRAINT "serverpod_future_call_claim_fk_0" FOREIGN KEY ("futureCallId") REFERENCES "serverpod_future_call" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "future_call_unique_idx" ON "serverpod_future_call_claim" ("futureCallId");


--
-- Class ServerHealthConnectionInfo as table serverpod_health_connection_info
--
CREATE TABLE "serverpod_health_connection_info" (
    "id" INTEGER PRIMARY KEY,
    "serverId" TEXT NOT NULL,
    "timestamp" INTEGER NOT NULL,
    "active" INTEGER NOT NULL,
    "closing" INTEGER NOT NULL,
    "idle" INTEGER NOT NULL,
    "granularity" INTEGER NOT NULL
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_connection_info_timestamp_idx" ON "serverpod_health_connection_info" ("timestamp", "serverId", "granularity");


--
-- Class ServerHealthMetric as table serverpod_health_metric
--
CREATE TABLE "serverpod_health_metric" (
    "id" INTEGER PRIMARY KEY,
    "name" TEXT NOT NULL,
    "serverId" TEXT NOT NULL,
    "timestamp" INTEGER NOT NULL,
    "isHealthy" INTEGER NOT NULL,
    "value" REAL NOT NULL,
    "granularity" INTEGER NOT NULL
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_health_metric_timestamp_idx" ON "serverpod_health_metric" ("timestamp", "serverId", "name", "granularity");


--
-- Class LogEntry as table serverpod_log
--
CREATE TABLE "serverpod_log" (
    "id" INTEGER PRIMARY KEY,
    "sessionLogId" INTEGER NOT NULL,
    "messageId" INTEGER,
    "reference" TEXT,
    "serverId" TEXT NOT NULL,
    "time" INTEGER NOT NULL,
    "logLevel" INTEGER NOT NULL,
    "message" TEXT NOT NULL,
    "error" TEXT,
    "stackTrace" TEXT,
    "order" INTEGER NOT NULL,
    CONSTRAINT "serverpod_log_fk_0" FOREIGN KEY ("sessionLogId") REFERENCES "serverpod_session_log" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "serverpod_log_sessionLogId_idx" ON "serverpod_log" ("sessionLogId", "order");


--
-- Class MessageLogEntry as table serverpod_message_log
--
CREATE TABLE "serverpod_message_log" (
    "id" INTEGER PRIMARY KEY,
    "sessionLogId" INTEGER NOT NULL,
    "serverId" TEXT NOT NULL,
    "messageId" INTEGER NOT NULL,
    "endpoint" TEXT NOT NULL,
    "messageName" TEXT NOT NULL,
    "duration" REAL NOT NULL,
    "error" TEXT,
    "stackTrace" TEXT,
    "slow" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,
    CONSTRAINT "serverpod_message_log_fk_0" FOREIGN KEY ("sessionLogId") REFERENCES "serverpod_session_log" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "serverpod_message_log_sessionLogId_idx" ON "serverpod_message_log" ("sessionLogId", "order");


--
-- Class MethodInfo as table serverpod_method
--
CREATE TABLE "serverpod_method" (
    "id" INTEGER PRIMARY KEY,
    "endpoint" TEXT NOT NULL,
    "method" TEXT NOT NULL
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_method_endpoint_method_idx" ON "serverpod_method" ("endpoint", "method");


--
-- Class DatabaseMigrationVersion as table serverpod_migrations
--
CREATE TABLE "serverpod_migrations" (
    "id" INTEGER PRIMARY KEY,
    "module" TEXT NOT NULL,
    "version" TEXT NOT NULL,
    "timestamp" INTEGER
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_migrations_ids" ON "serverpod_migrations" ("module");


--
-- Class QueryLogEntry as table serverpod_query_log
--
CREATE TABLE "serverpod_query_log" (
    "id" INTEGER PRIMARY KEY,
    "serverId" TEXT NOT NULL,
    "sessionLogId" INTEGER NOT NULL,
    "messageId" INTEGER,
    "query" TEXT NOT NULL,
    "duration" REAL NOT NULL,
    "numRows" INTEGER,
    "error" TEXT,
    "stackTrace" TEXT,
    "slow" INTEGER NOT NULL,
    "order" INTEGER NOT NULL,
    CONSTRAINT "serverpod_query_log_fk_0" FOREIGN KEY ("sessionLogId") REFERENCES "serverpod_session_log" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "serverpod_query_log_sessionLogId_idx" ON "serverpod_query_log" ("sessionLogId", "order");


--
-- Class ReadWriteTestEntry as table serverpod_readwrite_test
--
CREATE TABLE "serverpod_readwrite_test" (
    "id" INTEGER PRIMARY KEY,
    "number" INTEGER NOT NULL
) STRICT;


--
-- Class RuntimeSettings as table serverpod_runtime_settings
--
CREATE TABLE "serverpod_runtime_settings" (
    "id" INTEGER PRIMARY KEY,
    "logSettings" TEXT NOT NULL,
    "logSettingsOverrides" TEXT NOT NULL,
    "logServiceCalls" INTEGER NOT NULL,
    "logMalformedCalls" INTEGER NOT NULL
) STRICT;


--
-- Class SessionLogEntry as table serverpod_session_log
--
CREATE TABLE "serverpod_session_log" (
    "id" INTEGER PRIMARY KEY,
    "serverId" TEXT NOT NULL,
    "time" INTEGER NOT NULL,
    "module" TEXT,
    "endpoint" TEXT,
    "method" TEXT,
    "duration" REAL,
    "numQueries" INTEGER,
    "slow" INTEGER,
    "error" TEXT,
    "stackTrace" TEXT,
    "authenticatedUserId" INTEGER,
    "userId" TEXT,
    "isOpen" INTEGER,
    "touched" INTEGER NOT NULL
) STRICT;

-- Indexes
CREATE INDEX "serverpod_session_log_serverid_idx" ON "serverpod_session_log" ("serverId");
CREATE INDEX "serverpod_session_log_time_idx" ON "serverpod_session_log" ("time");
CREATE INDEX "serverpod_session_log_touched_idx" ON "serverpod_session_log" ("touched");
CREATE INDEX "serverpod_session_log_isopen_idx" ON "serverpod_session_log" ("isOpen");


--
-- Class AnonymousAccount as table serverpod_auth_idp_anonymous_account
--
CREATE TABLE "serverpod_auth_idp_anonymous_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL,
    CONSTRAINT "serverpod_auth_idp_anonymous_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;


--
-- Class AppleAccount as table serverpod_auth_idp_apple_account
--
CREATE TABLE "serverpod_auth_idp_apple_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "userIdentifier" TEXT NOT NULL,
    "refreshToken" TEXT NOT NULL,
    "refreshTokenRequestedWithBundleIdentifier" INTEGER NOT NULL,
    "lastRefreshedAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "authUserId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "email" TEXT,
    "isEmailVerified" INTEGER,
    "isPrivateEmail" INTEGER,
    "firstName" TEXT,
    "lastName" TEXT,
    CONSTRAINT "serverpod_auth_idp_apple_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_apple_account_identifier" ON "serverpod_auth_idp_apple_account" ("userIdentifier");


--
-- Class EmailAccount as table serverpod_auth_idp_email_account
--
CREATE TABLE "serverpod_auth_idp_email_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "email" TEXT NOT NULL,
    "passwordHash" TEXT NOT NULL,
    CONSTRAINT "serverpod_auth_idp_email_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_email" ON "serverpod_auth_idp_email_account" ("email");


--
-- Class EmailAccountOtpLoginRequest as table serverpod_auth_idp_email_account_otp_login_request
--
CREATE TABLE "serverpod_auth_idp_email_account_otp_login_request" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "email" TEXT NOT NULL,
    "challengeId" BLOB NOT NULL,
    "completeChallengeId" BLOB,
    CONSTRAINT "serverpod_auth_idp_email_account_otp_login_request_fk_0" FOREIGN KEY ("challengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "serverpod_auth_idp_email_account_otp_login_request_fk_1" FOREIGN KEY ("completeChallengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_otp_login_request_email" ON "serverpod_auth_idp_email_account_otp_login_request" ("email");


--
-- Class EmailAccountPasswordResetRequest as table serverpod_auth_idp_email_account_password_reset_request
--
CREATE TABLE "serverpod_auth_idp_email_account_password_reset_request" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "emailAccountId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "challengeId" BLOB NOT NULL,
    "setPasswordChallengeId" BLOB,
    CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_0" FOREIGN KEY ("emailAccountId") REFERENCES "serverpod_auth_idp_email_account" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_1" FOREIGN KEY ("challengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "serverpod_auth_idp_email_account_password_reset_request_fk_2" FOREIGN KEY ("setPasswordChallengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;


--
-- Class EmailAccountRequest as table serverpod_auth_idp_email_account_request
--
CREATE TABLE "serverpod_auth_idp_email_account_request" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "email" TEXT NOT NULL,
    "challengeId" BLOB NOT NULL,
    "createAccountChallengeId" BLOB,
    CONSTRAINT "serverpod_auth_idp_email_account_request_fk_0" FOREIGN KEY ("challengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "serverpod_auth_idp_email_account_request_fk_1" FOREIGN KEY ("createAccountChallengeId") REFERENCES "serverpod_auth_idp_secret_challenge" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_email_account_request_email" ON "serverpod_auth_idp_email_account_request" ("email");


--
-- Class FacebookAccount as table serverpod_auth_idp_facebook_account
--
CREATE TABLE "serverpod_auth_idp_facebook_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "userIdentifier" TEXT NOT NULL,
    "email" TEXT,
    "fullName" TEXT,
    "firstName" TEXT,
    "lastName" TEXT,
    CONSTRAINT "serverpod_auth_idp_facebook_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_facebook_account_user_identifier" ON "serverpod_auth_idp_facebook_account" ("userIdentifier");


--
-- Class FirebaseAccount as table serverpod_auth_idp_firebase_account
--
CREATE TABLE "serverpod_auth_idp_firebase_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "created" INTEGER NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "userIdentifier" TEXT NOT NULL,
    CONSTRAINT "serverpod_auth_idp_firebase_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_firebase_account_user_identifier" ON "serverpod_auth_idp_firebase_account" ("userIdentifier");


--
-- Class GitHubAccount as table serverpod_auth_idp_github_account
--
CREATE TABLE "serverpod_auth_idp_github_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "userIdentifier" TEXT NOT NULL,
    "email" TEXT,
    "created" INTEGER NOT NULL,
    CONSTRAINT "serverpod_auth_idp_github_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_github_account_user_identifier" ON "serverpod_auth_idp_github_account" ("userIdentifier");


--
-- Class GoogleAccount as table serverpod_auth_idp_google_account
--
CREATE TABLE "serverpod_auth_idp_google_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "created" INTEGER NOT NULL,
    "email" TEXT NOT NULL,
    "userIdentifier" TEXT NOT NULL,
    CONSTRAINT "serverpod_auth_idp_google_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_google_account_user_identifier" ON "serverpod_auth_idp_google_account" ("userIdentifier");


--
-- Class MicrosoftAccount as table serverpod_auth_idp_microsoft_account
--
CREATE TABLE "serverpod_auth_idp_microsoft_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "userIdentifier" TEXT NOT NULL,
    "email" TEXT,
    "created" INTEGER NOT NULL,
    CONSTRAINT "serverpod_auth_idp_microsoft_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_microsoft_account_user_identifier" ON "serverpod_auth_idp_microsoft_account" ("userIdentifier");


--
-- Class PasskeyAccount as table serverpod_auth_idp_passkey_account
--
CREATE TABLE "serverpod_auth_idp_passkey_account" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL,
    "keyId" BLOB NOT NULL,
    "keyIdBase64" TEXT NOT NULL,
    "clientDataJSON" BLOB NOT NULL,
    "attestationObject" BLOB NOT NULL,
    "originalChallenge" BLOB NOT NULL,
    CONSTRAINT "serverpod_auth_idp_passkey_account_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_idp_passkey_account_key_id_base64" ON "serverpod_auth_idp_passkey_account" ("keyIdBase64");


--
-- Class PasskeyChallenge as table serverpod_auth_idp_passkey_challenge
--
CREATE TABLE "serverpod_auth_idp_passkey_challenge" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "createdAt" INTEGER NOT NULL,
    "challenge" BLOB NOT NULL
) STRICT;


--
-- Class RateLimitedRequestAttempt as table serverpod_auth_idp_rate_limited_request_attempt
--
CREATE TABLE "serverpod_auth_idp_rate_limited_request_attempt" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "domain" TEXT NOT NULL,
    "source" TEXT NOT NULL,
    "key" TEXT NOT NULL,
    "ipAddress" TEXT,
    "attemptedAt" INTEGER NOT NULL,
    "extraData" TEXT
) STRICT;

-- Indexes
CREATE INDEX "serverpod_auth_idp_rate_limited_request_attempt_composite" ON "serverpod_auth_idp_rate_limited_request_attempt" ("domain", "source", "key", "attemptedAt");


--
-- Class SecretChallenge as table serverpod_auth_idp_secret_challenge
--
CREATE TABLE "serverpod_auth_idp_secret_challenge" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "challengeCodeHash" TEXT NOT NULL
) STRICT;


--
-- Class RefreshToken as table serverpod_auth_core_jwt_refresh_token
--
CREATE TABLE "serverpod_auth_core_jwt_refresh_token" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "scopeNames" TEXT NOT NULL,
    "extraClaims" TEXT,
    "method" TEXT NOT NULL,
    "fixedSecret" BLOB NOT NULL,
    "rotatingSecretHash" TEXT NOT NULL,
    "lastUpdatedAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    CONSTRAINT "serverpod_auth_core_jwt_refresh_token_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE INDEX "serverpod_auth_core_jwt_refresh_token_last_updated_at" ON "serverpod_auth_core_jwt_refresh_token" ("lastUpdatedAt");


--
-- Class UserProfile as table serverpod_auth_core_profile
--
CREATE TABLE "serverpod_auth_core_profile" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "userName" TEXT,
    "fullName" TEXT,
    "email" TEXT,
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "imageId" BLOB,
    CONSTRAINT "serverpod_auth_core_profile_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT "serverpod_auth_core_profile_fk_1" FOREIGN KEY ("imageId") REFERENCES "serverpod_auth_core_profile_image" ("id") ON DELETE NO ACTION ON UPDATE NO ACTION DEFERRABLE INITIALLY DEFERRED
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "serverpod_auth_profile_user_profile_email_auth_user_id" ON "serverpod_auth_core_profile" ("authUserId");


--
-- Class UserProfileImage as table serverpod_auth_core_profile_image
--
CREATE TABLE "serverpod_auth_core_profile_image" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "userProfileId" BLOB NOT NULL,
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "storageId" TEXT NOT NULL,
    "path" TEXT NOT NULL,
    "url" TEXT NOT NULL,
    CONSTRAINT "serverpod_auth_core_profile_image_fk_0" FOREIGN KEY ("userProfileId") REFERENCES "serverpod_auth_core_profile" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;


--
-- Class ServerSideSession as table serverpod_auth_core_session
--
CREATE TABLE "serverpod_auth_core_session" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "authUserId" BLOB NOT NULL,
    "scopeNames" TEXT NOT NULL,
    "createdAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "lastUsedAt" INTEGER NOT NULL DEFAULT (CAST(unixepoch('subsecond') * 1000 AS INTEGER)),
    "expiresAt" INTEGER,
    "expireAfterUnusedFor" INTEGER,
    "sessionKeyHash" BLOB NOT NULL,
    "sessionKeySalt" BLOB NOT NULL,
    "method" TEXT NOT NULL,
    CONSTRAINT "serverpod_auth_core_session_fk_0" FOREIGN KEY ("authUserId") REFERENCES "serverpod_auth_core_user" ("id") ON DELETE CASCADE ON UPDATE NO ACTION
) STRICT;


--
-- Class AuthUser as table serverpod_auth_core_user
--
CREATE TABLE "serverpod_auth_core_user" (
    "id" BLOB PRIMARY KEY DEFAULT (unhex(printf('%012x', CAST(unixepoch('now', 'subsecond') * 1000 AS INTEGER)) || '7' || substr(hex(randomblob(2)), 2, 3) || substr('89AB', 1 + (abs(random()) % 4), 1) || substr(hex(randomblob(8)), 2, 15))),
    "createdAt" INTEGER NOT NULL,
    "scopeNames" TEXT NOT NULL,
    "blocked" INTEGER NOT NULL
) STRICT;


--
-- STORE COLUMN TYPES FOR MIGRATIONS
--
DROP TABLE IF EXISTS "serverpod_sqlite_schema";

CREATE TABLE "serverpod_sqlite_schema" (
    "table_name" TEXT NOT NULL,
    "column_name" TEXT NOT NULL,
    "column_type" TEXT NOT NULL,
    "column_vector_dimension" INTEGER,
    PRIMARY KEY ("table_name", "column_name")
);

INSERT INTO "serverpod_sqlite_schema" VALUES
    ('asset', 'created_at', 'timestampWithoutTimeZone', NULL),
    ('best_score', 'achieved_at', 'timestampWithoutTimeZone', NULL),
    ('challenge', 'created_at', 'timestampWithoutTimeZone', NULL),
    ('challenge_revision', 'published_at', 'timestampWithoutTimeZone', NULL),
    ('challenge_revision', 'created_at', 'timestampWithoutTimeZone', NULL),
    ('play_session', 'id', 'uuid', NULL),
    ('play_session', 'request_id', 'uuid', NULL),
    ('play_session', 'started_at', 'timestampWithoutTimeZone', NULL),
    ('play_session', 'expires_at', 'timestampWithoutTimeZone', NULL),
    ('shot', 'request_id', 'uuid', NULL),
    ('shot', 'play_session_id', 'uuid', NULL),
    ('shot', 'best_achieve_time_at_submission', 'timestampWithoutTimeZone', NULL),
    ('shot', 'created_at', 'timestampWithoutTimeZone', NULL),
    ('user_profile', 'auth_user_id', 'uuid', NULL),
    ('user_profile', 'created_at', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'addedTime', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'expiration', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage', 'verified', 'boolean', NULL),
    ('serverpod_cloud_storage_direct_download', 'expiration', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage_direct_upload', 'expiration', 'timestampWithoutTimeZone', NULL),
    ('serverpod_cloud_storage_direct_upload', 'preventOverwrite', 'boolean', NULL),
    ('serverpod_future_call', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_future_call', 'scheduling', 'json', NULL),
    ('serverpod_future_call_claim', 'lastHeartbeatTime', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_connection_info', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_metric', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_health_metric', 'isHealthy', 'boolean', NULL),
    ('serverpod_log', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_message_log', 'slow', 'boolean', NULL),
    ('serverpod_migrations', 'timestamp', 'timestampWithoutTimeZone', NULL),
    ('serverpod_query_log', 'slow', 'boolean', NULL),
    ('serverpod_runtime_settings', 'logSettings', 'json', NULL),
    ('serverpod_runtime_settings', 'logSettingsOverrides', 'json', NULL),
    ('serverpod_runtime_settings', 'logServiceCalls', 'boolean', NULL),
    ('serverpod_runtime_settings', 'logMalformedCalls', 'boolean', NULL),
    ('serverpod_session_log', 'time', 'timestampWithoutTimeZone', NULL),
    ('serverpod_session_log', 'slow', 'boolean', NULL),
    ('serverpod_session_log', 'isOpen', 'boolean', NULL),
    ('serverpod_session_log', 'touched', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_anonymous_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_anonymous_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_anonymous_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_apple_account', 'refreshTokenRequestedWithBundleIdentifier', 'boolean', NULL),
    ('serverpod_auth_idp_apple_account', 'lastRefreshedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_apple_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_apple_account', 'isEmailVerified', 'boolean', NULL),
    ('serverpod_auth_idp_apple_account', 'isPrivateEmail', 'boolean', NULL),
    ('serverpod_auth_idp_email_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_otp_login_request', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_otp_login_request', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_otp_login_request', 'challengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_otp_login_request', 'completeChallengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'emailAccountId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'challengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_password_reset_request', 'setPasswordChallengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_email_account_request', 'challengeId', 'uuid', NULL),
    ('serverpod_auth_idp_email_account_request', 'createAccountChallengeId', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_facebook_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_firebase_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_firebase_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_firebase_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_github_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_github_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_github_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_google_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_google_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_google_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_microsoft_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_microsoft_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_microsoft_account', 'created', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_passkey_account', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_account', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_account', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_passkey_challenge', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_passkey_challenge', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'id', 'uuid', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'attemptedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_idp_rate_limited_request_attempt', 'extraData', 'json', NULL),
    ('serverpod_auth_idp_secret_challenge', 'id', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'id', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'lastUpdatedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_jwt_refresh_token', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_profile', 'id', 'uuid', NULL),
    ('serverpod_auth_core_profile', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_profile', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_profile', 'imageId', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'id', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'userProfileId', 'uuid', NULL),
    ('serverpod_auth_core_profile_image', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'id', 'uuid', NULL),
    ('serverpod_auth_core_session', 'authUserId', 'uuid', NULL),
    ('serverpod_auth_core_session', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_session', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'lastUsedAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_session', 'expiresAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_user', 'id', 'uuid', NULL),
    ('serverpod_auth_core_user', 'createdAt', 'timestampWithoutTimeZone', NULL),
    ('serverpod_auth_core_user', 'scopeNames', 'json', NULL),
    ('serverpod_auth_core_user', 'blocked', 'boolean', NULL);

--
-- MIGRATION VERSION FOR photohunt
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('photohunt', '20261108173011520', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261108173011520', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20261015164015382', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261015164015382', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260924105232991', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260924105232991', "timestamp" = (unixepoch('now', 'subsecond') * 1000);


COMMIT;
