
#!/bin/bash
set -e

# デフォルトの設定ファイル作成
if [ ! -f /etc/gitlab/gitlab.rb ]; then
    cat > /etc/gitlab/gitlab.rb << EOF
external_url 'http://0.0.0.0:3000'
nginx['listen_port'] = 3000
nginx['listen_addresses'] = ['0.0.0.0']
gitlab_workhorse['listen_network'] = 'tcp'
gitlab_workhorse['listen_addr'] = '0.0.0.0:3000'
unicorn['port'] = 3000
unicorn['listen'] = '0.0.0.0'
postgresql['port'] = 5432
redis['port'] = 6379
prometheus_monitoring['enable'] = false
nginx['status']['port'] = 3001
nginx['status']['options']['listen_addresses'] = ['0.0.0.0']
EOF
fi

# Render環境変数による設定
configure_gitlab() {
    if [ -n "$PORT" ]; then
        # PORTが設定されている場合、その値を使用
        sed -i "s/3000/$PORT/g" /etc/gitlab/gitlab.rb
    fi

    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        # RENDER_EXTERNAL_URLが設定されている場合、external_urlを更新
        sed -i "s|external_url 'http://0.0.0.0:3000'|external_url '$RENDER_EXTERNAL_URL'|g" /etc/gitlab/gitlab.rb
    fi
}

# 設定の適用
configure_gitlab

# ポートの待機確認
wait_for_port() {
    local port="$1"
    echo "Waiting for port $port to be available..."
    while ! nc -z 0.0.0.0 "$port"; do
        sleep 1
    done
    echo "Port $port is now available"
}

# GitLabの起動
exec /assets/wrapper