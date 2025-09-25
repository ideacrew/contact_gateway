module ContactEvents
  class ScheduleSmsMessage
    include Sidekiq::Worker
    include EventSource::Command

    sidekiq_options lock: :until_executing,
                    on_conflict: :replace,
                    unique_across_queues: true,
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
