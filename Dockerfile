FROM gitlab/gitlab-ce:latest

# 必要なパッケージ (tzdata はタイムゾーン設定に必要)
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# エントリポイントスクリプトをコピー
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Render では CMD で起動コマンドを指定
CMD ["/docker-entrypoint.sh"]