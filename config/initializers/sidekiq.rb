# Sidekiq configuration
Sidekiq.configure_server do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

Sidekiq.configure_client do |config|
  config.redis = { url: "redis://localhost:6379/0" }
end

# Configure queues
Sidekiq.configure_server do |config|
  config.queues = %w[default bulk high low]
end
