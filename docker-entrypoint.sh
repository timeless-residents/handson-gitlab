#!/bin/bash
set -e

# GITLAB_OMNIBUS_CONFIG に設定を追加する関数 (シングルクォートをエスケープ)
append_to_config() {
  local value="$1"
  # シングルクォートを \' にエスケープ
  value="${value//\'/\'}"

  if [ -n "$GITLAB_OMNIBUS_CONFIG" ]; then
    export GITLAB_OMNIBUS_CONFIG="$GITLAB_OMNIBUS_CONFIG;"
  fi
  export GITLAB_OMNIBUS_CONFIG="$GITLAB_OMNIBUS_CONFIG$value"
}

# Render 環境変数による GitLab 設定
configure_gitlab() {
  # Puma を有効にし、Unicorn を無効にする (最優先)
  append_to_config "puma['enable'] = true"
  append_to_config "unicorn['enable'] = false"

  # External URL
  if [ -n "$RENDER_EXTERNAL_URL" ]; then
    append_to_config "external_url '$RENDER_EXTERNAL_URL'"
  fi

  # ポート設定 (Render の環境変数 PORT, デフォルトは 10000)
  if [ -n "$PORT" ]; then
    append_to_config "nginx['listen_port'] = $PORT"
    append_to_config "gitlab_workhorse['listen_addr'] = '0.0.0.0:$PORT'"
  fi

  # データベース設定 (DATABASE_URL が存在する場合のみ設定)
  if [ -n "$DATABASE_URL" ]; then
    # DATABASE_URL のパース
    db_params=$(echo "$DATABASE_URL" | awk -F'[/:]' '{
      user=$4; pass=$5; host=$6; port=$7; db=$8
      gsub(/%[0-9A-Fa-f]{2}/,"",user); gsub(/%[0-9A-Fa-f]{2}/,"",pass)
      gsub(/@.*/,"",user); gsub(/.*@/,"",pass)
      printf "postgresql://%s:%s@%s:%s/%s", user, pass, host, port, db
    }')
    IFS=':' read -r user pass host port dbname <<< "$db_params"

    append_to_config "gitlab_rails['db_adapter'] = 'postgresql'"
    append_to_config "gitlab_rails['db_encoding'] = 'utf8'"
    append_to_config "gitlab_rails['db_username'] = '$user'"
    append_to_config "gitlab_rails['db_password'] = '$pass'" # パスワードに注意!
    append_to_config "gitlab_rails['db_host'] = '$host'"
    append_to_config "gitlab_rails['db_port'] = $port"
    append_to_config "gitlab_rails['db_database'] = '$dbname'"
    # 内部 PostgreSQL を無効化
    append_to_config "postgresql['enable'] = false"
  fi

  # Redis 設定
  if [ -n "$REDIS_HOST" ]; then
    append_to_config "redis['host'] = '$REDIS_HOST'"
    append_to_config "gitlab_rails['redis_host'] = '$REDIS_HOST'"
  fi
  if [ -n "$REDIS_PORT" ]; then
    append_to_config "redis['port'] = $REDIS_PORT"
    append_to_config "gitlab_rails['redis_port'] = '$REDIS_PORT'"
  fi
  if [ -n "$REDIS_PASSWORD" ]; then
    append_to_config "redis['password'] = '$REDIS_PASSWORD'" # パスワードに注意!
    append_to_config "gitlab_rails['redis_password'] = '$REDIS_PASSWORD'"
  fi
  # 内部 Redis を無効化
  append_to_config "redis['enable'] = false"
}

# 設定の適用
configure_gitlab

# GitLab の起動
exec /assets/wrapper