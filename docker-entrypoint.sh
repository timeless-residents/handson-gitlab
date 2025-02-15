#!/bin/bash
set -e

# Render 環境変数による GitLab 設定
configure_gitlab() {
  # GitLab の設定ファイル (Omnibus GitLab の設定)
  local gitlab_rb="/etc/gitlab/gitlab.rb"

  # External URL (Render の環境変数から取得)
  if [ -n "$RENDER_EXTERNAL_URL" ]; then
    echo "Setting external_url to $RENDER_EXTERNAL_URL"
    sed -i "s|external_url .*|external_url '$RENDER_EXTERNAL_URL'|g" "$gitlab_rb"
  fi

  # ポート設定 (Render の環境変数 PORT, デフォルトは 10000)
  if [ -n "$PORT" ]; then
    echo "Setting nginx listen port to $PORT"
    sed -i "s/nginx\['listen_port'\] =.*/nginx['listen_port'] = $PORT/g" "$gitlab_rb"
    sed -i "s/gitlab_workhorse\['listen_addr'\] =.*/gitlab_workhorse['listen_addr'] = \"0.0.0.0:$PORT\"/g" "$gitlab_rb"
  fi
  
  # データベース設定 (Render の PostgreSQL サービスを使う場合)
  if [ -n "$DATABASE_URL" ]; then
      echo "Configuring database connection using DATABASE_URL"
       # GitLab 14 以降での DATABASE_URL のパース処理
      db_params=$(echo "$DATABASE_URL" | awk -F'[/:]' '{
        user=$4; pass=$5; host=$6; port=$7; db=$8
        gsub(/%[0-9A-Fa-f]{2}/,"",user); gsub(/%[0-9A-Fa-f]{2}/,"",pass)
        gsub(/@.*/,"",user); gsub(/.*@/,"",pass)
        printf "postgresql://%s:%s@%s:%s/%s", user, pass, host, port, db
      }')
      IFS=':' read -r user pass host port dbname <<< "$db_params"

      sed -i "s|postgresql\['enable'\] =.*|postgresql['enable'] = false|g" "$gitlab_rb"
      sed -i "s|gitlab_rails\['db_username'\] =.*|gitlab_rails['db_username'] = \"$user\"|g" "$gitlab_rb"
      sed -i "s|gitlab_rails\['db_password'\] =.*|gitlab_rails['db_password'] = \"$pass\"|g" "$gitlab_rb"
      sed -i "s|gitlab_rails\['db_host'\] =.*|gitlab_rails['db_host'] = \"$host\"|g" "$gitlab_rb"
      sed -i "s|gitlab_rails\['db_port'\] =.*|gitlab_rails['db_port'] = $port|g" "$gitlab_rb"
      sed -i "s|gitlab_rails\['db_database'\] =.*|gitlab_rails['db_database'] = \"$dbname\"|g" "$gitlab_rb"

  fi


  # Redis 設定 (Render の Redis サービス または 外部 Redis を使う場合)
    if [ -n "$REDIS_HOST" ]; then
        echo "Setting Redis host to $REDIS_HOST"
        sed -i "s|redis\['host'\] =.*|redis['host'] = \"$REDIS_HOST\"|g" "$gitlab_rb"
    fi

    if [ -n "$REDIS_PORT" ]; then
        echo "Setting Redis port to $REDIS_PORT"
        sed -i "s|redis\['port'\] =.*|redis['port'] = $REDIS_PORT|g" "$gitlab_rb"
    fi
    # Redis パスワード (必要な場合)
    if [ -n "$REDIS_PASSWORD" ]; then
        echo "Setting Redis password"
        sed -i "s|redis\['password'\] =.*|redis['password'] = \"$REDIS_PASSWORD\"|g" "$gitlab_rb"
    fi
}

# 設定の適用
configure_gitlab

# GitLab の起動
exec /assets/wrapper