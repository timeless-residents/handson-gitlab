FROM gitlab/gitlab-ce:latest

# システムの依存関係をインストール
RUN apt-get update && apt-get install -y \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# タイムゾーンを設定
ENV TZ=Asia/Tokyo

# GitLab設定
ENV GITLAB_OMNIBUS_CONFIG="external_url 'https://handson-gitlab.onrender.com'; \
    puma['worker_processes']=2; \
    puma['min_threads']=1; \
    puma['max_threads']=4; \
    postgresql['shared_buffers']='128MB'; \
    postgresql['max_connections']=100; \
    nginx['worker_processes']=2; \
    sidekiq['concurrency']=5; \
    prometheus_monitoring['enable']=false; \
    nginx['listen_port']=ENV['PORT']"

# ポートの設定
EXPOSE ${PORT:-80}

# 起動コマンド
CMD ["sh", "-c", "gitlab-ctl reconfigure && gitlab-ctl start && tail -f /dev/null"]