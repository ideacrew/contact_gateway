contact_gateway_sidekiq_redis_url = ENV["CONTACT_GATEWAY_REDIS_JOB_SERVER_URL"] || "redis://localhost:6379"

contact_gateway_blocklist_schedule = ENV["CONTACT_GATEWAY_SMS_BLOCKLIST_UPDATE_SCHEDULE"] || "0 0 13 * * *" # Run about 1pm every day

contact_gateway_sms_blocklist_update_is_enabled = (ENV["CONTACT_GATEWAY_SMS_BLOCKLIST_UPDATE_IS_ENABLED"] == "true")

Sidekiq.configure_server do |config|
  config.redis = { url: contact_gateway_sidekiq_redis_url }
  if contact_gateway_sms_blocklist_update_is_enabled
    config.on(:startup) do
      Sidekiq.schedule = {
        update_sms_blocklist: {
          cron: contact_gateway_blocklist_schedule, # Run about 1pm every day
          class: "ContactEvents::PerformScheduledSmsBlocklistUpdate"
        }
      }
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: contact_gateway_sidekiq_redis_url }
end
