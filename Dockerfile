
FROM gitlab/gitlab-ce:latest

# システム依存関係のインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# GitLabの初期設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:10000'; \
    gitlab_workhorse['listen_network'] = 'tcp'; \
    gitlab_workhorse['listen_addr'] = '0.0.0.0:10000'; \
    nginx['listen_port'] = 10000; \
    nginx['listen_addresses'] = ['0.0.0.0']; \
    postgresql['port'] = 5432; \
    redis['port'] = 6379; \
    prometheus_monitoring['enable'] = false;"

# 必要なディレクトリを作成
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab && \
    chmod -R 755 /etc/gitlab /var/log/gitlab /var/opt/gitlab

# ポートの公開
EXPOSE 10000 22 443

# カスタム起動スクリプトの追加
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]