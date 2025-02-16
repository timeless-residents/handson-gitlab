# 基本URL設定
external_url 'https://handson-gitlab.onrender.com'

# Pumaの最小設定
puma['worker_processes'] = 2
puma['min_threads'] = 1
puma['max_threads'] = 4

# PostgreSQLの最小設定
postgresql['enable'] = true
postgresql['shared_buffers'] = "128MB"

# Redisの最小設定
redis['maxmemory'] = "256mb"
redis['maxmemory_policy'] = "allkeys-lru"

# Nginxの最小設定
nginx['worker_processes'] = 2

# Sidekiqの最小設定
sidekiq['concurrency'] = 5

# メモリ使用量の最適化
postgresql['max_connections'] = 100
prometheus_monitoring['enable'] = false

# Render.com用のポート設定
nginx['listen_port'] = ENV['PORT'] || 80