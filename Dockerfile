FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定
ENV PORT=8080

# GitLabの設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:${PORT}'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    package['detect_init_system'] = false; \
    nginx['listen_port'] = ${PORT}"

# 必要なディレクトリを作成
RUN mkdir -p /run/sshd

# Renderが検出するポートを公開
EXPOSE ${PORT}