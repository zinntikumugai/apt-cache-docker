# APT Cacher NG Docker Image

[![Build and Push Docker Image](https://github.com/user/apt-cache-docker/actions/workflows/docker-build.yml/badge.svg)](https://github.com/user/apt-cache-docker/actions/workflows/docker-build.yml)
[![Release](https://github.com/user/apt-cache-docker/actions/workflows/release.yml/badge.svg)](https://github.com/user/apt-cache-docker/actions/workflows/release.yml)

Debian Trixie Slimをベースにしたapt-cacher-ngのDockerイメージです。

## ✨ 特徴

- **ベースイメージ**: `debian:trixie-slim` (バージョン固定)
- **アプリケーション**: `apt-cacher-ng` (バージョン固定)
- **自動更新**: Renovate Botによる依存関係の監視
- **CI/CD**: GitHub Actionsによる自動ビルドとリリース
- **マルチアーキテクチャ**: `linux/amd64`, `linux/arm64` サポート
- **バージョン管理**: セマンティックバージョニングとapt-cacher-ngバージョンの組み合わせ

## 🏷️ バージョン管理とタグ

このプロジェクトでは以下のバージョンが固定されています：

- **Debian base image**: `trixie-slim`
- **apt-cacher-ng**: `3.7.4-1+b2`

### タグ体系

| タグ | 説明 |
|------|------|
| `latest` | 最新の安定版 |
| `apt-cacher-ng-{version}` | apt-cacher-ngのバージョン固有 |
| `v{release}-apt-cacher-ng-{version}` | リリース版とapt-cacher-ngバージョンの組み合わせ |
| `v{version}-build-{date}-{sha}` | 詳細なビルド情報付き |
| `{date}` | 日付ベースタグ |

### 自動更新

Renovate Botが自動的に新しいバージョンをチェックし、プルリクエストを作成します。

## 🚀 クイックスタート

### GitHub Container Registry (GHCR) から取得

> **注意**: このプロジェクトはGitHub Container Registry (GHCR) のみを使用し、Docker Hubは使用していません。

```bash
# 最新版を取得
docker pull ghcr.io/user/apt-cache-docker:latest

# 特定のバージョンを取得
docker pull ghcr.io/user/apt-cache-docker:apt-cacher-ng-3.7.4-1+b2

# GHCR認証が必要な場合
echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
```

### Makefileを使用した管理

```bash
# ヘルプを表示
make help

# ビルドと実行
make dev

# サービス開始
make run

# ログを確認
make logs

# テスト実行
make test

# クリーンアップ
make clean
```

### 手動でのビルドと実行

#### イメージのビルド
```bash
docker build -t apt-cacher-ng:latest .
```

#### コンテナの実行
```bash
docker run -d \
  -p 3142:3142 \
  -v apt-cacher-data:/var/cache/apt-cacher-ng \
  --name apt-cacher \
  apt-cacher-ng:latest
```

#### Docker Composeでの実行
```bash
docker-compose up -d
```

## 🔧 クライアント設定

### 自動設定（Makefile使用）

```bash
# クライアント設定を追加
make setup-client

# クライアント設定を削除
make remove-client
```

### 手動設定

他のDebianシステムで以下の設定を追加：

```bash
echo 'Acquire::HTTP::Proxy "http://localhost:3142";' | sudo tee /etc/apt/apt.conf.d/01proxy
```

### 設定確認

```bash
# apt-cacher-ngが動作しているか確認
curl http://localhost:3142/acng-report.html

# パッケージ更新テスト
sudo apt update
```

## 🤖 CI/CD パイプライン

### GitHub Actions ワークフロー

1. **自動ビルド** (`.github/workflows/docker-build.yml`)
   - **レジストリ**: GitHub Container Registry (GHCR) のみ
   - プッシュ、プルリクエスト、手動トリガーで実行
   - マルチアーキテクチャビルド（amd64, arm64）
   - apt-cacher-ngバージョンの自動抽出
   - 複数のタグを自動生成
   - **Docker Hubは使用しません**

2. **リリース管理** (`.github/workflows/release.yml`)
   - **レジストリ**: GitHub Container Registry (GHCR) のみ
   - 手動トリガーでリリース作成
   - セマンティックバージョニング
   - GitHub Releaseの自動作成
   - リリースノートの自動生成

### タグの自動生成

- `latest`: デフォルトブランチの最新
- `apt-cacher-ng-{version}`: apt-cacher-ngバージョン固有
- `v{version}-build-{date}-{sha}`: 詳細ビルド情報
- `{date}`: 日付ベース

## 🔄 自動更新

### Renovate Bot設定

`renovate.json` ファイルで以下の設定を行っています：

- Dockerイメージの自動更新チェック
- Debian パッケージの自動更新チェック
- 毎週月曜日の朝6時前にスケジュール実行
- 日本時間での実行

## 📋 仕様

### ポート

- `3142`: apt-cacher-ngのデフォルトポート

### ボリューム

- `/var/cache/apt-cacher-ng`: キャッシュデータの永続化

### プラットフォーム

- `linux/amd64`
- `linux/arm64`

## 🧪 開発とテスト

### 開発環境のセットアップ

```bash
# リポジトリをクローン
git clone https://github.com/user/apt-cache-docker.git
cd apt-cache-docker

# 開発用ビルドと起動
make dev

# ログの確認
make logs

# テスト実行
make test
```

### リリース手順

1. GitHub Actions の "Release" ワークフローを手動実行
2. バージョン番号を指定（例: `v1.0.0`）
3. 自動的にタグ付けとリリース作成が実行される