#!/bin/bash
set -e

# 環境変数の設定
export GITLAB_OMNIBUS_CONFIG="$GITLAB_OMNIBUS_CONFIG"

# GitLabの起動（シンプル化）
exec /opt/gitlab/embedded/bin/gitlab-ctl start