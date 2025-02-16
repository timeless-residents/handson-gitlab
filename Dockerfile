#==========================================================
# Dockerfile
#==========================================================
FROM gitlab/gitlab-ce:latest

# 必要に応じて追加パッケージなどをインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV TZ=Asia/Tokyo

# Omnibus GitLab の設定を ENV に詰め込む
#  - detect_init_system を false にする
#  - (もしデータディレクトリを変更するなら git_data_dir を記載)
#  - external_url や puma/postgresql/redis/nginx 設定もまとめて記載
ENV GITLAB_OMNIBUS_CONFIG=" \
  package['detect_init_system'] = false; \
  external_url 'https://handson-gitlab.onrender.com'; \
  # ↓ git_data_dirs は非推奨なので削除、または置き換え
  # git_data_dir '/var/opt/gitlab/git-data'; \
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
  # Render 等で PORT 環境変数が提供される場合を考慮
  nginx['listen_port'] = ENV['PORT'] || 80; \
  nginx['listen_https'] = false; \
  prometheus_monitoring['enable'] = false; \
  gitlab_workhorse['enable'] = true; \
  gitlab_workhorse['listen_network'] = 'tcp'; \
  gitlab_workhorse['listen_addr'] = '0.0.0.0:' + (ENV['PORT'] || 80).to_s;"

# GitLab 用ディレクトリの作成および権限付与
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab \
    && chmod 777 /var/opt/gitlab /var/log/gitlab

# runit 用のサービスディレクトリを準備（GitLab CE イメージに準ずる）
RUN mkdir -p /opt/gitlab/sv/gitlab-runsvdir/supervise \
    && mkfifo /opt/gitlab/sv/gitlab-runsvdir/supervise/ok \
    && printf "#!/bin/sh\nexec 2>&1\numask 077\nexec /usr/bin/runsvdir -P /opt/gitlab/service\n" > /opt/gitlab/sv/gitlab-runsvdir/run \
    && chmod a+x /opt/gitlab/sv/gitlab-runsvdir/run \
    && ln -s /opt/gitlab/sv/gitlab-runsvdir /opt/gitlab/service

EXPOSE ${PORT:-80}

# エントリーポイントスクリプトを COPY
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]