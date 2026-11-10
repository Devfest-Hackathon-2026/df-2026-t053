# build context はリポジトリのルート: docker build -f api/Dockerfile .
# DART_VERSION は mise が使う Dart（Flutter 同梱）と同じ版にする。`mise //:doctor` で照合する。
ARG DART_VERSION=3.13.7

FROM dart:${DART_VERSION} AS build
WORKDIR /src
COPY . .
WORKDIR /src/api
# Serverpod 本体と運用 CLI（所有権・DB 検証・複製確認）、seed CLI、migration Job の CLI を
# 別々の bundle にする。
RUN dart pub get \
 && dart build cli -t bin/main.dart -o /out/main \
 && dart build cli -t bin/ops.dart -o /out/ops \
 && dart build cli -t bin/seed.dart -o /out/seed \
 && dart build cli -t bin/migrate.dart -o /out/migrate

# Litestream（D09）。POST /sync を使える v0.5.9 以降のうち、スパイクで GCS への複製と
# IPC の応答を確認した版を、バイナリの SHA-256 とあわせて固定する。
FROM debian:bookworm-slim AS litestream
ARG TARGETARCH
ARG LITESTREAM_VERSION=0.5.18
ARG LITESTREAM_SHA256_AMD64=d3687b9fd0f2e9426bbd3da828429ff3f1dfc5c9b74d54fdf028e4ee510e7dea
ARG LITESTREAM_SHA256_ARM64=922a09e6a7ac67f2095571894dc6382e94e1dd4cdd9674883ddf1a8e74ab982d
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    case "$TARGETARCH" in \
      amd64) arch=x86_64; sha="$LITESTREAM_SHA256_AMD64" ;; \
      arm64) arch=arm64;  sha="$LITESTREAM_SHA256_ARM64" ;; \
      *) echo "未対応のアーキテクチャ: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    file="litestream-${LITESTREAM_VERSION}-linux-${arch}.tar.gz"; \
    curl -fsSL -o "/tmp/$file" "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/$file"; \
    echo "$sha  /tmp/$file" | sha256sum -c -; \
    tar -xzf "/tmp/$file" -C /usr/local/bin litestream; \
    litestream version

# 実行用。コンテナ内では mise に依存しない。
FROM debian:bookworm-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /data /var/run
COPY --from=litestream /usr/local/bin/litestream /usr/local/bin/litestream
WORKDIR /app
COPY --from=build /out/main/bundle/ /app/main/
COPY --from=build /out/ops/bundle/ /app/ops/
COPY --from=build /out/seed/bundle/ /app/seed/
COPY --from=build /out/migrate/bundle/ /app/migrate/
COPY api/config /app/config
COPY api/migrations /app/migrations
COPY api/scripts /app/scripts
RUN chmod +x /app/scripts/*.sh
ENV RELEASE_ID=dev
# 所有権取得 → 復元 → 検証 → Litestream → Serverpod の順に起動する。
# API の起動には --apply-migrations を付けない。スキーマ変更は専用 Job だけで行う。
ENTRYPOINT ["/app/scripts/start.sh"]
