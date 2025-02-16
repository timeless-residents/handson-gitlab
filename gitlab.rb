# 基本設定
external_url 'https://handson-gitlab.onrender.com'

# Pumaの設定（Unicornの代わり）
puma['worker_processes'] = 2
puma['min_threads'] = 1
puma['max_threads'] = 16
puma['per_worker_max_memory_mb'] = 300

# PostgreSQLの設定
postgresql['enable'] = true
postgresql['shared_buffers'] = "256MB"
postgresql['max_connections'] = 200

# Nginxの設定
nginx['worker_processes'] = 2
nginx['worker_connections'] = 2048

# Sidekiqの設定
sidekiq['concurrency'] = 10

# メモリ設定の最適化
puma['worker_max_memory_mb'] = 512

# Gitaly設定
gitaly['configuration'] = {
  socket_path: "/var/opt/gitlab/gitaly/gitaly.socket",
  listen_addr: "localhost:8075"
}

# メール設定（必要に応じて）
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "tl.sato.takuya@gmail.com"
gitlab_rails['smtp_password'] = "ZAV2rkvr"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true

# SSLの設定（Let's Encryptを使用する場合）
letsencrypt['enable'] = true
letsencrypt['contact_emails'] = ['tl.sato.takuya@example.com']
