# 基本設定
external_url 'https://handson-gitlab.onrender.com'

# SSHの設定
gitlab_rails['gitlab_shell_ssh_port'] = 22

# データベース設定
postgresql['enable'] = true
postgresql['shared_buffers'] = "256MB"
postgresql['max_connections'] = 200

# メモリ設定の最適化
unicorn['worker_processes'] = 2
unicorn['worker_memory_limit_min'] = "200*1024*1024"
unicorn['worker_memory_limit_max'] = "300*1024*1024"

# Sidekiqの設定
sidekiq['concurrency'] = 10

# Nginxの設定
nginx['worker_processes'] = 2
nginx['worker_connections'] = 2048

# メール設定
gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.gmail.com"
gitlab_rails['smtp_port'] = 587
gitlab_rails['smtp_user_name'] = "tl.sato.takuya@gmail.com"
gitlab_rails['smtp_password'] = "ZAV2rkvr"
gitlab_rails['smtp_domain'] = "smtp.gmail.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['gitlab_email_from'] = 'tl.sato.takuya@gmail.com'
