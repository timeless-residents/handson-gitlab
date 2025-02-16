FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定
ENV PORT=8080

# 設定ファイルを作成
RUN echo "external_url 'http://0.0.0.0:${PORT}'" >> /etc/gitlab/gitlab.rb && \
    echo "nginx['listen_address'] = '0.0.0.0'" >> /etc/gitlab/gitlab.rb && \
    echo "nginx['listen_port'] = ${PORT}" >> /etc/gitlab/gitlab.rb && \
    echo "gitlab_workhorse['listen_network'] = 'tcp'" >> /etc/gitlab/gitlab.rb && \
    echo "gitlab_workhorse['listen_addr'] = '0.0.0.0:${PORT}'" >> /etc/gitlab/gitlab.rb && \
    echo "package['detect_init_system'] = false" >> /etc/gitlab/gitlab.rb

# 起動スクリプトを作成
RUN echo '#!/bin/bash\n\
    gitlab-ctl reconfigure\n\
    gitlab-ctl start\n\
    /opt/gitlab/embedded/bin/nginx -g "daemon off;"' > /startup.sh && \
    chmod +x /startup.sh

# ポートを開く
EXPOSE ${PORT}

# 起動コマンドを指定
CMD ["/startup.sh"]