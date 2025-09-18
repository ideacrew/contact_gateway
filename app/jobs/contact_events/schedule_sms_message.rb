module ContactEvents
  class ScheduleSmsMessage
    include Sidekiq::Job
    include EventSource::Command

    sidekiq_options lock: :until_executed,
                    on_conflict: :replace,
                    lock_args_method: :lock_args

    def perform(phone, message, timestamp)
      event_result = event(
        "events.contact_events.sms_message.transmit",
        attributes: {
          phone: phone,
          message: message,
          submitted_at: timestamp
        }
      )
      event_result.success.publish
    end

    def self.lock_args(args)
      [ args[0], args[1] ]
    end
  end
end
