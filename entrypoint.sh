#!/bin/bash
set -e

# GitLab設定の更新
gitlab-ctl reconfigure

# GitLabの起動
gitlab-ctl start

# コンテナの起動を維持
exec "$@"