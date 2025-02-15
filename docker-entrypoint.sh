#!/bin/bash
set -e

# /etc/gitlab/gitlab.rbが存在しない場合は、デフォルトの設定ファイルを作成
# ※デフォルト値は0.0.0.0で待ち受けるように変更
if [ ! -f /etc/gitlab/gitlab.rb ]; then
    echo "external_url 'http://0.0.0.0:8080'" > /etc/gitlab/gitlab.rb
fi

# GitLabの設定をRenderの環境変数で上書きする関数
configure_gitlab() {
    # Render固有の環境変数 RENDER_EXTERNAL_URL がセットされていれば
    if [ -n "$RENDER_EXTERNAL_URL" ]; then
        export EXTERNAL_URL="$RENDER_EXTERNAL_URL"
        # /etc/gitlab/gitlab.rb 内の external_url を更新
        sed -i "s|external_url 'http://0.0.0.0:8080'|external_url '$RENDER_EXTERNAL_URL'|g" /etc/gitlab/gitlab.rb
    fi

    # Render が提供する PORT 環境変数で Puma のポートを更新
    if [ -n "$PORT" ]; then
        sed -i "s/puma\['port'\] = 8080/puma\['port'\] = $PORT/g" /etc/gitlab/gitlab.rb
    fi

    # 必要に応じて他の設定変更をここに追加可能
}

# GitLab設定の反映
configure_gitlab

# GitLab本体の起動（GitLab Omnibusイメージのwrapperを実行）
exec /assets/wrapper
