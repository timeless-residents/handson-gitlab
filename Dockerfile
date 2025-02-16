# Dockerfile
FROM gitlab/gitlab-ce:latest

# システム依存関係のインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーン
ENV TZ=Asia/Tokyo

# Omnibus GitLab 設定: init システム検出を無効化し、各種設定を上書き
ENV GITLAB_OMNIBUS_CONFIG="package['detect_init_system'] = false; \
    external_url 'https://handson-gitlab.onrender.com'; \
    puma['enable'] = true; \
    puma['worker_processes'] = 2; \
    puma['min_threads'] = 1; \
    puma['max_threads'] = 4; \
    puma['per_worker_max_memory_mb'] = 300; \
    postgresql['enable'] = true; \
    postgresql['shared_buffers'] = '128MB'; \
    postgresql['max_connections'] = 100; \
    redis['maxmemory'] = '256mb'; \
    redis['maxmemory_policy'] = 'allkeys-lru'; \
    nginx['enable'] = true; \
    nginx['worker_processes'] = 2; \
    nginx['listen_port'] = ENV['PORT'] || 80; \
    nginx['listen_https'] = false; \
    prometheus_monitoring['enable'] = false; \
    gitlab_workhorse['enable'] = true; \
    gitlab_workhorse['listen_network'] = 'tcp'; \
    gitlab_workhorse['listen_addr'] = '0.0.0.0:' + (ENV['PORT'] || 80).to_s;"

# 必要なディレクトリの作成＆権限付与
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab \
    && chmod 777 /var/opt/gitlab /var/log/gitlab

# runit 用のディレクトリ作成（GitLab CE イメージ標準に近い形）
RUN mkdir -p /opt/gitlab/sv/gitlab-runsvdir/supervise \
    && mkfifo /opt/gitlab/sv/gitlab-runsvdir/supervise/ok \
    && printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/bin/runsvdir -P /opt/gitlab/service\n" > /opt/gitlab/sv/gitlab-runsvdir/run \
    && chmod a+x /opt/gitlab/sv/gitlab-runsvdir/run \
    && ln -s /opt/gitlab/sv/gitlab-runsvdir /opt/gitlab/service

# ポート公開 (Render 側では ENV['PORT'] をセットする想定)
EXPOSE ${PORT:-80}

# エントリーポイントスクリプトをコピー
# （以下のスクリプト例では gitlab-ctl reconfigure → start を行うなど）
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# 実行
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]
