Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'], reconnect_attempts: 3 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV['REDIS_URL'], reconnect_attempts: 3 }
end

Sidekiq.default_worker_options = { 'retry' => 3 }
