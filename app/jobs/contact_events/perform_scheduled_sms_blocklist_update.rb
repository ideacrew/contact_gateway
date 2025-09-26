module ContactEvents
  class PerformScheduledSmsBlocklistUpdate
    include Sidekiq::Job
    include EventSource::Command

    def perform
      event("events.sms_blocklist.update_process.trigger", attributes: {}).success.publish
    end
  end
end
