BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "challenge_revision" ADD COLUMN "seed_digest" TEXT;

--
-- #26: 公開済みの版と子データの更新・削除を禁止する（手書き）。
-- 公開処理は published_at が null の版にだけ値を入れるので、この UPDATE は通る。
--
CREATE TRIGGER "challenge_revision_published_no_update" BEFORE UPDATE ON "challenge_revision"
WHEN OLD."published_at" IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "challenge_revision_published_no_delete" BEFORE DELETE ON "challenge_revision"
WHEN OLD."published_at" IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision cannot be deleted');
END;
CREATE TRIGGER "mode_config_published_no_insert" BEFORE INSERT ON "mode_config"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = NEW."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "mode_config_published_no_update" BEFORE UPDATE ON "mode_config"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" IN (OLD."revision_id", NEW."revision_id") AND "published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "mode_config_published_no_delete" BEFORE DELETE ON "mode_config"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = OLD."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "spawn_point_published_no_insert" BEFORE INSERT ON "spawn_point"
WHEN (SELECT r."published_at" FROM "mode_config" m JOIN "challenge_revision" r ON r."id" = m."revision_id" WHERE m."id" = NEW."mode_config_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "spawn_point_published_no_update" BEFORE UPDATE ON "spawn_point"
WHEN (SELECT r."published_at" FROM "mode_config" m JOIN "challenge_revision" r ON r."id" = m."revision_id" WHERE m."id" IN (OLD."mode_config_id", NEW."mode_config_id") AND r."published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "spawn_point_published_no_delete" BEFORE DELETE ON "spawn_point"
WHEN (SELECT r."published_at" FROM "mode_config" m JOIN "challenge_revision" r ON r."id" = m."revision_id" WHERE m."id" = OLD."mode_config_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "landmark_published_no_insert" BEFORE INSERT ON "landmark"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = NEW."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "landmark_published_no_update" BEFORE UPDATE ON "landmark"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" IN (OLD."revision_id", NEW."revision_id") AND "published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "landmark_published_no_delete" BEFORE DELETE ON "landmark"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = OLD."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "credit_published_no_insert" BEFORE INSERT ON "credit"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = NEW."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "credit_published_no_update" BEFORE UPDATE ON "credit"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" IN (OLD."revision_id", NEW."revision_id") AND "published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "credit_published_no_delete" BEFORE DELETE ON "credit"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = OLD."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_published_no_insert" BEFORE INSERT ON "structure"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = NEW."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_published_no_update" BEFORE UPDATE ON "structure"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" IN (OLD."revision_id", NEW."revision_id") AND "published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_published_no_delete" BEFORE DELETE ON "structure"
WHEN (SELECT "published_at" FROM "challenge_revision" WHERE "id" = OLD."revision_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_source_published_no_insert" BEFORE INSERT ON "structure_source"
WHEN (SELECT r."published_at" FROM "structure" s JOIN "challenge_revision" r ON r."id" = s."revision_id" WHERE s."id" = NEW."structure_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_source_published_no_update" BEFORE UPDATE ON "structure_source"
WHEN (SELECT r."published_at" FROM "structure" s JOIN "challenge_revision" r ON r."id" = s."revision_id" WHERE s."id" IN (OLD."structure_id", NEW."structure_id") AND r."published_at" IS NOT NULL) IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
CREATE TRIGGER "structure_source_published_no_delete" BEFORE DELETE ON "structure_source"
WHEN (SELECT r."published_at" FROM "structure" s JOIN "challenge_revision" r ON r."id" = s."revision_id" WHERE s."id" = OLD."structure_id") IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'published challenge_revision is immutable');
END;
--
-- #26: current_revision_id は自分の出題の公開済みの版だけを指す（手書き）。
--
CREATE TRIGGER "challenge_current_revision_insert_ck" BEFORE INSERT ON "challenge"
WHEN NEW."current_revision_id" IS NOT NULL
BEGIN
    SELECT RAISE(ABORT, 'current_revision_id must be a published revision of the challenge');
END;
CREATE TRIGGER "challenge_current_revision_update_ck" BEFORE UPDATE OF "current_revision_id", "id" ON "challenge"
WHEN NEW."current_revision_id" IS NOT NULL AND NOT EXISTS (
    SELECT 1 FROM "challenge_revision"
    WHERE "id" = NEW."current_revision_id" AND "challenge_id" = NEW."id" AND "published_at" IS NOT NULL
)
BEGIN
    SELECT RAISE(ABORT, 'current_revision_id must be a published revision of the challenge');
END;

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
    VALUES ('photohunt', '20261108174814867', (unixepoch('now', 'subsecond') * 1000))
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261108174814867', "timestamp" = (unixepoch('now', 'subsecond') * 1000);

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
