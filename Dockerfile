# GitLab CE イメージ (ARM64 用)
FROM gitlab/gitlab-ce:latest

# 必要なパッケージ (tzdata はタイムゾーン設定に必要)
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# 環境変数 (Render で設定するものをデフォルト値として設定)
# GitLab のバージョンによっては、これらの設定が不要な場合もあります
ENV RAILS_ENV=production
ENV DB_ADAPTER=postgresql
ENV DB_HOST= 
ENV DB_NAME= 
ENV DB_USER= 
ENV DB_PASS= 
ENV DB_PORT=5432
ENV REDIS_HOST= 
ENV REDIS_PORT=6379

# エントリポイントスクリプトをコピー
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Render では CMD で起動コマンドを指定
CMD ["/docker-entrypoint.sh"]