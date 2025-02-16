#!/bin/bash
set -e

# ユーザが引数付きでコンテナを起動した場合の処理（bashやgitlabコマンドを直接指定した場合）
if [[ "$1" == "bash" || "$1" == "gitlab-ctl" || "$1" == "gitlab-rake" ]]; then
    exec "$@"
fi

# 環境変数で与えられたOmnibus設定を/etc/gitlab/gitlab.rbに適用
if [[ -n "${GITLAB_OMNIBUS_CONFIG}" ]]; then
    echo "${GITLAB_OMNIBUS_CONFIG}" > /etc/gitlab/gitlab.rb
fi

# Runit（GitLab内蔵のサービス管理）をバックグラウンドで起動
/opt/gitlab/embedded/bin/runsvdir-start &

# GitLabの設定を反映してサービスを起動
gitlab-ctl reconfigure

# フォアグラウンドでログを出力しつつプロセスを維持
exec gitlab-ctl tail
