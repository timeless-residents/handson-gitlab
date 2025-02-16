#!/bin/bash

# GitLabの設定を適用
gitlab-ctl reconfigure

# Nginxを明示的に再起動
gitlab-ctl restart nginx

# ポートが開いているか確認
netstat -tulpn | grep LISTEN

# GitLabのプロセスを維持
exec tail -f /dev/null