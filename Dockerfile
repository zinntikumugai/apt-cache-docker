# Debian Trixie Slim ベースのapt-cacher-ng イメージ
# renovate: datasource=docker depName=debian versioning=docker
FROM debian:trixie-slim

# ビルド引数
ARG BUILDTIME
ARG VERSION

# メタデータ
LABEL maintainer="user"
LABEL description="APT Cacher NG on Debian Trixie Slim"
LABEL version="1.0"
LABEL org.opencontainers.image.created="${BUILDTIME}"
LABEL org.opencontainers.image.title="APT Cacher NG"
LABEL org.opencontainers.image.description="APT Cacher NG proxy server on Debian Trixie Slim"
LABEL org.opencontainers.image.vendor="user"
LABEL org.opencontainers.image.licenses="GPL-2.0"
LABEL apt-cacher-ng.version="${VERSION}"

# 環境変数
ENV DEBIAN_FRONTEND=noninteractive
# renovate: datasource=repology depName=debian_13/apt-cacher-ng versioning=loose
ENV APT_CACHER_NG_VERSION=3.7.5

# システムの更新とapt-cacher-ngのインストール（バージョン固定）
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-cacher-ng=${APT_CACHER_NG_VERSION}* \
        curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# apt-cacher-ngの設定ディレクトリを作成
RUN mkdir -p /var/cache/apt-cacher-ng \
    && chown apt-cacher-ng:apt-cacher-ng /var/cache/apt-cacher-ng

# ポート3142を公開（apt-cacher-ngのデフォルトポート）
EXPOSE 3142

# ボリューム設定（キャッシュデータの永続化用）
VOLUME ["/var/cache/apt-cacher-ng"]

# ヘルスチェック
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3142/acng-report.html || exit 1

# apt-cacher-ngサービスを開始
CMD ["/usr/sbin/apt-cacher-ng", "-c", "/etc/apt-cacher-ng", "ForeGround=1"]