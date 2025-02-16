# Dockerfile
FROM gitlab/gitlab-ce:latest

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# デフォルトポートを設定
ENV PORT=10080

# GitLab設定を環境変数で上書き
ENV GITLAB_OMNIBUS_CONFIG="external_url 'https://handson-gitlab.onrender.com'; \
    unicorn['enable'] = false; \
    puma['enable'] = true; \
    puma['worker_processes'] = 2; \
    puma['min_threads'] = 1; \
    puma['max_threads'] = 4; \
    puma['per_worker_max_memory_mb'] = 300; \
    puma['listen'] = '0.0.0.0:#{ENV[\"PORT\"]}'; \
    postgresql['enable'] = true; \
    postgresql['shared_buffers'] = '128MB'; \
    postgresql['max_connections'] = 100; \
    redis['maxmemory'] = '256mb'; \
    redis['maxmemory_policy'] = 'allkeys-lru'; \
    nginx['enable'] = true; \
    nginx['worker_processes'] = 2; \
    nginx['listen_port'] = ENV['PORT']; \
    nginx['listen_https'] = false; \
    prometheus_monitoring['enable'] = false; \
    gitlab_workhorse['enable'] = true; \
    gitlab_workhorse['listen_network'] = 'tcp'; \
    gitlab_workhorse['listen_addr'] = '0.0.0.0:#{ENV[\"PORT\"]}';"

# ポートを明示的に公開
EXPOSE ${PORT}

# ヘルスチェック用の設定
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/users/sign_in || exit 1

# 起動コマンド
CMD ["sh", "-c", "echo 'Configuring GitLab...' && \
    gitlab-ctl reconfigure && \
    echo 'Starting GitLab...' && \
    gitlab-ctl start && \
    echo 'GitLab started on port ${PORT}' && \
    tail -f /var/log/gitlab/gitlab-rails/production.log"]
