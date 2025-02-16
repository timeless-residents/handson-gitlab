#!/bin/bash
set -e

# システムの初期化
/assets/wrapper &

# ポートが開いているか確認
while ! nc -z localhost ${PORT}; do
  echo "Waiting for port ${PORT}..."
  sleep 1
done

# プロセスを維持
tail -f /dev/null