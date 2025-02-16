FROM debian:12

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定（必須）
ENV PORT=10000

# 環境変数の設定
ENV BACKUP_TIME="0 12 * * *" \
    PATH=/opt/gitlab/embedded/bin:/opt/gitlab/bin:/assets:$PATH \
    TERM=xterm \
    PACKAGECLOUD_REPO=gitlab-ce \
    RELEASE_PACKAGE=gitlab-ce \
    RELEASE_VERSION=16.1.2-ce.0 \
    DOWNLOAD_URL=https://packages.gitlab.com/gitlab/gitlab-ce/packages/debian/bookworm/gitlab-ce_16.1.2-ce.0_amd64.deb/download.deb

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
    python3 \
    curl && \
    rm -rf /var/lib/apt/lists/* && \
    sed 's/session\s*required\s*pam_loginuid.so/session optional pam_loginuid.so/g' -i /etc/pam.d/sshd && \
    rm -rf /etc/update-motd.d /etc/motd /etc/motd.dynamic && \
    ln -fs /dev/null /run/motd. && \
    mkdir -p /run/sshd /var/log/gitlab/nginx /assets && \
    # GitLabパッケージのダウンロードとインストール
    wget --quiet ${DOWNLOAD_URL} -O /tmp/gitlab.deb && \
    dpkg -i /tmp/gitlab.deb && \
    rm /tmp/gitlab.deb

# GitLabの設定
ENV GITLAB_OMNIBUS_CONFIG="\
    external_url 'http://0.0.0.0:${PORT}'; \
    nginx['listen_port'] = ${PORT}; \
    nginx['listen_address'] = '0.0.0.0'; \
    puma['port'] = ${PORT}; \
    puma['worker_processes'] = 2; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22"

# 一時的なWebサーバーを作成（ポート検出用）
RUN echo '#!/bin/bash\n\
    python3 -m http.server ${PORT} --bind 0.0.0.0 &\n\
    P1=$!\n\
    sleep 5\n\
    kill $P1\n\
    exec /opt/gitlab/bin/gitlab-ctl reconfigure && \
    exec /opt/gitlab/bin/gitlab-ctl start && \
    tail -f /dev/null\n\
    ' > /start.sh && chmod +x /start.sh

EXPOSE ${PORT}

# コマンドの設定
CMD ["/start.sh"]