FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定
ENV PORT=8080

# GitLabの設定
ENV GITLAB_OMNIBUS_CONFIG="\
    package['detect_init'] = false; \
    external_url 'http://0.0.0.0:${PORT}'; \
    nginx['enable'] = true; \
    nginx['listen_port'] = ${PORT}; \
    nginx['listen_address'] = '0.0.0.0'; \
    puma['enable'] = true; \
    puma['listen'] = '0.0.0.0'; \
    puma['port'] = ${PORT}; \
    puma['worker_processes'] = 2; \
    prometheus_monitoring['enable'] = false; \
    gitlab_rails['auto_migrate'] = true; \
    postgresql['enable'] = true; \
    postgresql['shared_buffers'] = '256MB'; \
    redis['enable'] = true; \
    sidekiq['concurrency'] = 5; \
    # ログディレクトリの権限を設定 \
    logging['svlogd_size'] = 200 * 1024 * 1024; \
    logging['svlogd_num'] = 30; \
    # ReadOnlyFileSystem対策 \
    gitlab_rails['env'] = { 'TMPDIR' => '/tmp' }"

# 必要なディレクトリを作成し、権限を設定
RUN mkdir -p /run/sshd /var/log/gitlab/nginx /var/opt/gitlab/gitlab-rails && \
    chmod -R 755 /var/log/gitlab

# 単純なウェブサーバーを追加してポート検出を確実にする
RUN apt-get update && apt-get install -y python3

# 起動スクリプトを作成
RUN echo '#!/bin/bash\n\
    \n\
    # GitLabの権限を更新\n\
    update-permissions\n\
    \n\
    # 一時的なWebサーバーを起動（ポート検出用）\n\
    python3 -m http.server ${PORT} --bind 0.0.0.0 &\n\
    TEMP_SERVER_PID=$!\n\
    \n\
    # GitLabの起動\n\
    /assets/wrapper &\n\
    \n\
    # 設定の適用を待つ\n\
    sleep 30\n\
    \n\
    # 一時的なWebサーバーを停止\n\
    kill $TEMP_SERVER_PID\n\
    \n\
    # NGINXのログディレクトリが存在することを確認\n\
    mkdir -p /var/log/gitlab/nginx\n\
    touch /var/log/gitlab/nginx/access.log\n\
    \n\
    # プロセスを維持\n\
    tail -f /var/log/gitlab/nginx/access.log\n\
    ' > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE ${PORT}

ENTRYPOINT ["/entrypoint.sh"]