# GitHub Container Registry (GHCR) Configuration

## About GHCR

このプロジェクトはGitHub Container Registry (GHCR) のみを使用し、Docker Hubは使用していません。

## レジストリ情報

- **Registry**: `ghcr.io`
- **Repository**: `ghcr.io/user/apt-cache-docker`
- **Visibility**: Public (デフォルト)

## 認証

### Personal Access Token (PAT) の作成

1. GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 以下のスコープを選択:
   - `read:packages`
   - `write:packages` 
   - `delete:packages` (オプション)

### ローカル認証

```bash
# 環境変数にトークンを設定
export GITHUB_TOKEN=your_token_here

# GHCRにログイン
echo $GITHUB_TOKEN | docker login ghcr.io -u your_username --password-stdin

# または Makefileを使用
make ghcr-login
```

### GitHub Actions 認証

GitHub ActionsではGITHUB_TOKENが自動的に利用可能で、追加設定は不要です。

## イメージの取得

### パブリックイメージ (認証不要)

```bash
# 最新版
docker pull ghcr.io/user/apt-cache-docker:latest

# 特定バージョン
docker pull ghcr.io/user/apt-cache-docker:apt-cacher-ng-3.7.4-1+b2
```

### プライベートイメージ (認証必要)

```bash
# 事前にログイン
echo $GITHUB_TOKEN | docker login ghcr.io -u username --password-stdin

# イメージ取得
docker pull ghcr.io/user/apt-cache-docker:latest
```

## パッケージ管理

### 可視性の設定

1. GitHub Repository → Packages
2. パッケージを選択 → Package settings
3. "Change visibility" でPublic/Privateを切り替え

### パッケージの削除

```bash
# 特定のタグを削除 (要delete:packages権限)
docker image rm ghcr.io/user/apt-cache-docker:tag_name
```

## トラブルシューティング

### 認証エラー

```bash
# トークンの確認
echo $GITHUB_TOKEN

# 再ログイン
docker logout ghcr.io
echo $GITHUB_TOKEN | docker login ghcr.io -u username --password-stdin
```

### 権限エラー

- Personal Access Tokenのスコープを確認
- リポジトリのPackages設定を確認
- Organization設定でPackage accessを確認

## 参考リンク

- [GitHub Container Registry Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Authenticating to GitHub Packages](https://docs.github.com/en/packages/learn-github-packages/introduction-to-github-packages#authenticating-to-github-packages)