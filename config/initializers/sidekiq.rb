contact_gateway_sidekiq_redis_url = ENV["CONTACT_GATEWAY_REDIS_JOB_SERVER_URL"] || "redis://localhost:6379"

Sidekiq.configure_server do |config|
  config.redis = { url: contact_gateway_sidekiq_redis_url }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: contact_gateway_sidekiq_redis_url }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
