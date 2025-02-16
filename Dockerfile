FROM debian:12

# 環境変数の設定
ENV BACKUP_TIME="0 12 * * *" \
    PATH=/opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH \
    TERM=xterm \
    PACKAGECLOUD_REPO=gitlab-ce \
    RELEASE_PACKAGE=gitlab-ce \
    RELEASE_VERSION=16.1.2-ce.0 \
    DOWNLOAD_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_16.1.2-ce.0_amd64.deb/download.deb \
    PORT=8080

# コンテナファイルのコピー
COPY container-files /

# 必要なパッケージのインストールと設定
RUN apt-get update -q && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    ca-certificates \
    openssh-server \
    wget \
    apt-transport-https \
    vim \
    tzdata \
    cron \
    perl \
    nano \
    python3 && \
    rm -rf /var/lib/apt/lists/* && \
    sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd && \
    rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic && \
    ln -fs /dev/null /run/motd. && \
    /assets/setup && \
    mkdir -p /run/sshd /var/log/gitlab/nginx && \
    touch /.dockerenv

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
    logging['svlogd_size'] = 200 * 1024 * 1024; \
    logging['svlogd_num'] = 30; \
    gitlab_rails['env'] = { 'TMPDIR' => '/tmp' }; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22"

# 起動スクリプトの作成
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
    GITLAB_PID=$!\n\
    \n\
    # 設定の適用を待つ\n\
    sleep 30\n\
    \n\
    # 一時的なWebサーバーを停止\n\
    kill $TEMP_SERVER_PID\n\
    \n\
    # GitLabプロセスを前面で実行\n\
    wait $GITLAB_PID\n\
    ' > /entrypoint.sh && chmod +x /entrypoint.sh

# ヘルスチェックの設定
HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
    CMD curl -f http://localhost:${PORT}/ || exit 1

# ポートとボリュームの設定
EXPOSE ${PORT} 22
VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab"]

# エントリーポイントの設定
ENTRYPOINT ["/entrypoint.sh"]