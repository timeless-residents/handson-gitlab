FROM gitlab/gitlab-ce:latest

# コンテナ環境であることを示すファイルを作成
RUN touch /.dockerenv

# Render用のポート設定
ENV PORT=8080

# GitLabの設定
ENV GITLAB_OMNIBUS_CONFIG="\
    external_url 'http://0.0.0.0:${PORT}'; \
    nginx['listen_address'] = '0.0.0.0'; \
    nginx['listen_port'] = ${PORT}; \
    puma['port'] = ${PORT}; \
    puma['listen'] = '0.0.0.0:${PORT}'; \
    package['detect_init'] = false"

# 起動スクリプトを作成
RUN echo '#!/bin/bash\n\
    # システムの初期化と起動\n\
    /assets/wrapper &\n\
    # サービスの起動を待つ\n\
    sleep 30\n\
    while ! curl -s http://localhost:${PORT} > /dev/null; do\n\
    echo "Waiting for GitLab to start..."\n\
    sleep 5\n\
    done\n\
    echo "GitLab is up and running!"\n\
    # プロセスを維持\n\
    tail -f /dev/null' > /entrypoint.sh && \
    chmod +x /entrypoint.sh

EXPOSE ${PORT}

ENTRYPOINT ["/entrypoint.sh"]