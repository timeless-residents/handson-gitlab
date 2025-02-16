FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成（これが重要）
RUN touch /.dockerenv

# 必要なディレクトリを作成
RUN mkdir -p /run/sshd

# ポート設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:8080'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    package['detect_init_system'] = false"

EXPOSE 8080 22