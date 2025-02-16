FROM gitlab/gitlab-ce:latest

# 必要なパッケージ (tzdata はタイムゾーン設定に必要)
RUN apt-get update && apt-get install -y tzdata && rm -rf /var/lib/apt/lists/*

# ARG: ビルド時に値を渡せる (Render のビルド時に環境変数を設定)
# デフォルト値を設定しておくことも可能
ARG RAILS_ENV=production
ARG DB_ADAPTER=postgresql
ARG DATABASE_URL
ARG DB_HOST
ARG DB_NAME
ARG DB_USER
ARG DB_PASS
ARG DB_PORT=5432
ARG REDIS_HOST
ARG REDIS_PORT=6379
ARG REDIS_PASSWORD

# ENV: コンテナ内で常に利用可能な環境変数
# ARG で定義した値を ENV に引き継ぐ
ENV RAILS_ENV=$RAILS_ENV
ENV DATABASE_URL=$DATABASE_URL
ENV DB_ADAPTER=$DB_ADAPTER
ENV DB_HOST=$DB_HOST
ENV DB_NAME=$DB_NAME
ENV DB_USER=$DB_USER
ENV DB_PASS=$DB_PASS
ENV DB_PORT=$DB_PORT
ENV REDIS_HOST=$REDIS_HOST
ENV REDIS_PORT=$REDIS_PORT
ENV REDIS_PASSWORD=$REDIS_PASSWORD

# エントリポイントスクリプトをコピー
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

# Render では CMD で起動コマンドを指定
CMD ["/docker-entrypoint.sh"]