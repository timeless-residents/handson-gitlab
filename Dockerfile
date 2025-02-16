# Dockerfile for GitLab CE on Ubuntu 22.04
FROM ubuntu:22.04

# タイムゾーンを事前設定
ENV TZ=Asia/Tokyo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 基本ツールとGitLabリポジトリ追加に必要なパッケージをインストール
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    openssh-server \
    tzdata \
    perl && \
    rm -rf /var/lib/apt/lists/*



# GitLab公式パッケージリポジトリを追加
RUN curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | bash

# GitLab CEをインストール（initシステム検出を無効化）
ENV GITLAB_OMNIBUS_CONFIG="package['detect_init_system'] = false; \
    external_url 'http://localhost'; \
    git_data_dir '/var/opt/gitlab/git-data'; \
    puma['worker_processes'] = 0; \
    sidekiq['concurrency'] = 10; \
    prometheus_monitoring['enable'] = false"
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y gitlab-ce && \
    rm -rf /var/lib/apt/lists/*

# GitLabが使用するディレクトリをボリューム指定（データ永続化）
VOLUME /var/opt/gitlab /var/log/gitlab /etc/gitlab

# エントリポイントスクリプトをコピーして設定
COPY docker-entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/docker-entrypoint.sh

# デフォルトでSSHとHTTP(S)ポートを公開
EXPOSE 22 80 443

ENTRYPOINT ["docker-entrypoint.sh"]
