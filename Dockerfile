FROM gitlab/gitlab-ce:latest

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# 必要なディレクトリを作成
RUN mkdir -p /etc/gitlab /var/log/gitlab /var/opt/gitlab \
    && chmod 777 /var/opt/gitlab /var/log/gitlab

# GitLabの設定
COPY gitlab.rb /etc/gitlab/gitlab.rb

# ポートの設定
EXPOSE 22 80 443

# 起動スクリプト
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["tail", "-f", "/dev/null"]