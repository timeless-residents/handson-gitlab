#!/bin/bash
set -e

# GitLabの設定を適用
gitlab-ctl reconfigure || true

# SSHサービスを起動
/usr/sbin/sshd

# GitLabを起動
exec gitlab-ctl start && gitlab-ctl tail