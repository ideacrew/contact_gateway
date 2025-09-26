module ContactEvents
  class UpdateSmsBlocklist
    include Sidekiq::Job
    include EventSource::Command

    sidekiq_options lock: :until_and_while_executing,
                    lock_timeout: 2,
                    lock_ttl: 1.day,
                    on_conflict: {
                      client: :log,
                      server: :log
                    }

    def perform
      event("events.sms_blocklist.update.requested", attributes: {}).success.publish
    end
  end
end
