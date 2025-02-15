#!/bin/bash
set -e

# /etc/gitlab/gitlab.rbが存在しない場合は、デフォルトの設定ファイルを作成
if [ ! -f /etc/gitlab/gitlab.rb ]; then
    echo "external_url 'http://localhost:8080'" > /etc/gitlab/gitlab.rb
fi

# GitLabの設定をRenderの環境変数で上書きする関数
configure_gitlab() {
    # Render固有の環境変数 RE
    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        export EXTERNAL_URL="$RENDER_EXTERNAL_URL"
        # external_urlを更新
        sed -i "s|external_url 'http://localhost:8080'|external_url '$RENDER_EXTERNAL_URL'|g" /etc/gitlab/gitlab.rb
    fi

    # Renderが提供するPORT環境変数でPumaのポートを更新
    if [ -n "$PORT" ]; then
        sed -i "s/puma\['port'\] = 8080/puma\['port'\] = $PORT/g" /etc/gitlab/gitlab.rb
    fi

    # 必要に応じて他の設定をここに追加
}

# GitLab設定の反映
configure_gitlab

# GitLab本体の起動（GitLab Omnibusイメージのwrapperを実行）
exec /assets/wrapper
