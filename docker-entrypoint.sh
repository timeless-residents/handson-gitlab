#!/bin/bash
set -e

# デフォルトの設定ファイル作成
if [ ! -f /etc/gitlab/gitlab.rb ]; then
    echo "external_url 'http://0.0.0.0:10000'" > /etc/gitlab/gitlab.rb
    echo "gitlab_workhorse['listen_network'] = 'tcp'" >> /etc/gitlab/gitlab.rb
    echo "gitlab_workhorse['listen_addr'] = '0.0.0.0:10000'" >> /etc/gitlab/gitlab.rb
fi

# Render環境変数による設定
configure_gitlab() {
    if [ -n "$PORT" ]; then
        sed -i "s/10000/$PORT/g" /etc/gitlab/gitlab.rb
    fi

    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        sed -i "s|external_url 'http://0.0.0.0:10000'|external_url '$RENDER_EXTERNAL_URL'|g" /etc/gitlab/gitlab.rb
    fi
}

# 設定の適用
configure_gitlab

# GitLabの起動
exec /assets/wrapper