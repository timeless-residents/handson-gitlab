#!/bin/bash
set -e

# 環境変数の設定
function configure_gitlab() {
    # Render固有の環境変数を使用
    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        export EXTERNAL_URL="${RENDER_EXTERNAL_URL}"
    fi
}

# GitLabの初期化と起動
configure_gitlab
exec /assets/wrapper