FROM gitlab/gitlab-ce:latest

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# GitLab設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://localhost:8080/'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    unicorn['port'] = 8080; \
    postgresql['port'] = 5432; \
    redis['port'] = 6379; \
    prometheus_monitoring['enable'] = false;"

# 必要なディレクトリを作成
RUN mkdir -p /etc/gitlab \
    /var/log/gitlab \
    /var/opt/gitlab \
    && chmod -R 755 /etc/gitlab \
    && chmod -R 755 /var/log/gitlab \
    && chmod -R 755 /var/opt/gitlab

# ポートの公開
EXPOSE 8080 22 443

# ヘルスチェック
HEALTHCHECK --interval=60s --timeout=30s --retries=5 \
    CMD curl -f http://localhost/-/health || exit 1

# GitLab起動スクリプト
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]