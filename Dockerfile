FROM gitlab/gitlab-ce:latest

# 必要なシステム依存関係のインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# GitLabの初期設定 (Pumaへの移行とRender対応)
# ※ここでの external_url のデフォルトを 0.0.0.0 で待ち受けるように変更
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:8080'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    puma['port'] = 8080; \
    postgresql['port'] = 5432; \
    redis['port'] = 6379; \
    prometheus_monitoring['enable'] = false; \
    puma['enable'] = true; \
    unicorn['enable'] = false;"

# 必要なディレクトリを作成し、パーミッションを設定
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab && \
    chmod -R 755 /etc/gitlab /var/log/gitlab /var/opt/gitlab

# ポートの公開
EXPOSE 8080 22 443

# カスタムGitLab起動スクリプトをコピーして実行権限を付与
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD [""]
