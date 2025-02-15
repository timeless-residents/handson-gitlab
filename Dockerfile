
FROM gitlab/gitlab-ce:latest

# システム依存関係のインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# GitLabの初期設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:3000'; \
    nginx['listen_port'] = 3000; \
    nginx['listen_addresses'] = ['0.0.0.0']; \
    gitlab_workhorse['listen_network'] = 'tcp'; \
    gitlab_workhorse['listen_addr'] = '0.0.0.0:3000'; \
    unicorn['port'] = 3000; \
    unicorn['listen'] = '0.0.0.0'; \
    postgresql['port'] = 5432; \
    redis['port'] = 6379; \
    prometheus_monitoring['enable'] = false; \
    nginx['status']['port'] = 3001; \
    nginx['status']['options']['listen_addresses'] = ['0.0.0.0'];"

# 必要なディレクトリを作成
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab && \
    chmod -R 755 /etc/gitlab /var/log/gitlab /var/opt/gitlab

# ポートの公開
EXPOSE 3000 3001 22

# カスタム起動スクリプトの追加
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
