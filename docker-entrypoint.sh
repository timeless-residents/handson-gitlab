#!/bin/bash
set -e

# システムの初期化
/assets/wrapper &

# ポートの確認（BusyBox互換の方法）
while ! nc -w 1 localhost ${PORT} </dev/null; do
  echo "Waiting for port ${PORT}..."
  sleep 1
done

# プロセスを維持
tail -f /dev/null