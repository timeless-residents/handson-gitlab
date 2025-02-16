# Dockerfile for GitLab CE on Ubuntu 22.04
FROM ubuntu:22.04

# タイムゾーンを事前設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 基本ツールとGitLabリポジトリ追加に必要なパッケージをインストール
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    curl \
    openssh-server \
    tzdata \
    perl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# GitLab公式パッケージリポジトリを追加
RUN curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

# GitLab CEをインストール（Render環境向けに最適化）
ENV GITLAB_OMNIBUS_CONFIG="package['detect_init_system'] = false; \
    external_url 'http://0.0.0.0:${PORT}'; \
    unicorn['listen'] = '0.0.0.0'; \
    unicorn['port'] = '${PORT}'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    puma['worker_processes'] = 0; \
    sidekiq['concurrency'] = 2; \
    prometheus_monitoring['enable'] = false; \
    gitlab_rails['manage_storage_directories'] = false; \
    gitlab_rails['auto_migrate'] = false; \
    gitlab_workhorse['listen_network'] = 'tcp'; \
    gitlab_workhorse['listen_addr'] = '0.0.0.0:${PORT}'; \
    gitaly['enable'] = false; \
    postgresql['enable'] = false; \
    redis['enable'] = false; \
    nginx['enable'] = false; \
    prometheus['enable'] = false; \
    alertmanager['enable'] = false; \
    grafana['enable'] = false; \
    gitlab_rails['db_adapter'] = 'postgresql'; \
    gitlab_rails['db_database'] = 'gitlab'; \
    gitlab_rails['db_username'] = 'gitlab'; \
    gitlab_rails['db_password'] = 'gitlab'; \
    gitlab_rails['db_host'] = 'localhost'"

# ポートを明示的に指定
ENV PORT=8080

# 必要なディレクトリを作成
RUN mkdir -p /run/sshd

# エントリーポイントスクリプトをコピー
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

EXPOSE ${PORT}
ENTRYPOINT ["/docker-entrypoint.sh"]