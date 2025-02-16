FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定
ENV PORT=8080

# Init system detectionを無効化
ENV GITLAB_OMNIBUS_CONFIG="\
    package['detect_init'] = false; \
    external_url 'http://0.0.0.0:${PORT}'; \
    nginx['listen_address'] = '0.0.0.0'; \
    nginx['listen_port'] = ${PORT}; \
    puma['port'] = ${PORT}; \
    puma['listen'] = '0.0.0.0:${PORT}'; \
    puma['worker_processes'] = 0; \
    sidekiq['concurrency'] = 2; \
    prometheus_monitoring['enable'] = false; \
    gitaly['configuration'] = { 'listen_addr' => 'tcp://0.0.0.0:8075' }; \
    gitaly['enable'] = true; \
    gitlab_rails['trusted_proxies'] = ['0.0.0.0/0']; \
    postgresql['trust_auth_cidr_addresses'] = ['0.0.0.0/0']; \
    gitlab_rails['registry_enabled'] = false; \
    gitlab_rails['monitoring_whitelist'] = ['0.0.0.0/0']"

# 必要なディレクトリを作成
RUN mkdir -p /run/sshd

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]