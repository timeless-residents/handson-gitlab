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

# GitLab CEをインストール（initシステム検出を無効化）
ENV GITLAB_OMNIBUS_CONFIG="package['detect_init_system'] = false; \
    external_url 'http://0.0.0.0:${PORT}'; \
    gitlab_rails['gitlab_shell_ssh_port'] = 22; \
    puma['worker_processes'] = 0; \
    sidekiq['concurrency'] = 2; \
    prometheus_monitoring['enable'] = false"

# ポートを明示的に指定
ENV PORT=8080

# 必要なディレクトリを作成
RUN mkdir -p /run/sshd

EXPOSE ${PORT}
CMD ["gitlab-ctl", "reconfigure"]