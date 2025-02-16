# Dockerfile for GitLab CE on Ubuntu 22.04
FROM ubuntu:22.04

# タイムゾーンを事前設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

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

# GitLab CEをインストール
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y gitlab-ce && \
    rm -rf /var/lib/apt/lists/*

# GitLabの設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'http://0.0.0.0:8080'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    puma['worker_processes'] = 0; \
    sidekiq['concurrency'] = 2; \
    prometheus_monitoring['enable'] = false; \
    package['detect_init_system'] = false"

# SSHディレクトリを作成
RUN mkdir -p /run/sshd

EXPOSE 8080 22

# 起動スクリプト
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]