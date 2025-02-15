#!/bin/bash
set -e

# 環境変数の設定
function configure_gitlab() {
    # Render固有の環境変数を使用
    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        export EXTERNAL_URL="$RENDER_EXTERNAL_URL"
        # external_urlを更新
        sed -i "s|external_url 'http://localhost:8080'|external_url '$RENDER_EXTERNAL_URL'|g" /etc/gitlab/gitlab.rb
    fi

    # Renderから提供されるPORT環境変数を使用
    if [ -n "$PORT" ]; then
        # Pumaのポート設定を更新
        sed -i "s/puma\['port'\] = 8080/puma\['port'\] = $PORT/g" /etc/gitlab/gitlab.rb
    fi

    # 必要に応じて他の設定をここに追加
}

# GitLabの初期化と起動
configure_gitlab
exec /assets/wrapper