# Dockerfile
FROM gitlab/gitlab-ce:latest

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# GitLab設定ファイルをコピー
COPY gitlab.rb /etc/gitlab/gitlab.rb

# ポートの設定
EXPOSE ${PORT:-80}

# 起動コマンド
CMD ["sh", "-c", "gitlab-ctl reconfigure && gitlab-ctl start && tail -f /dev/null"]