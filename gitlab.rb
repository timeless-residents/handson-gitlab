# 基本URL設定
external_url 'https://handson-gitlab.onrender.com'

# Pumaの設定
puma['worker_processes'] = 2
puma['min_threads'] = 1
puma['max_threads'] = 4

# PostgreSQLの設定
postgresql['enable'] = true
postgresql['shared_buffers'] = "128MB"
postgresql['max_connections'] = 100

# Redisの設定
redis['maxmemory'] = "256mb"
redis['maxmemory_policy'] = "allkeys-lru"

# Nginxの設定
nginx['worker_processes'] = 2
nginx['listen_port'] = ENV['PORT'] || 80

# Sidekiqの設定
sidekiq['concurrency'] = 5

# メモリ使用量の最適化
prometheus_monitoring['enable'] = false

# GitLab Workhorse設定
gitlab_workhorse['listen_network'] = "tcp"
gitlab_workhorse['listen_addr'] = "0.0.0.0:#{ENV['PORT'] || 80}"