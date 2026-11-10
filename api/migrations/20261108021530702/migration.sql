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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
--
CREATE TABLE "challenge_revision" (
    "id" INTEGER PRIMARY KEY,
    "challenge_id" INTEGER NOT NULL,
    "revision_no" INTEGER NOT NULL,
    "scene_profile" TEXT NOT NULL,
    "scoring_version" TEXT NOT NULL,
    "photo_asset_id" INTEGER NOT NULL,
    "model_asset_id" INTEGER NOT NULL,
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
    CONSTRAINT "challenge_revision_fk_2" FOREIGN KEY ("model_asset_id") REFERENCES "asset" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION,
    CONSTRAINT "challenge_revision_fk_3" FOREIGN KEY ("map_asset_id") REFERENCES "asset" ("id") ON DELETE RESTRICT ON UPDATE NO ACTION
) STRICT;

-- Indexes
CREATE UNIQUE INDEX "challenge_revision_challenge_no_uk" ON "challenge_revision" ("challenge_id", "revision_no");

--
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
-- ACTION CREATE TABLE
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
    VALUES ('photohunt', '20261108021530702', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261108021530702', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

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
