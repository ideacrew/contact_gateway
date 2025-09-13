class TransmitSmsMessage
  include Dry::Monads[:result, :do, :try]
  include EventSource::Command

  def call(options = {})
    batch_schedule = SmsBatchSchedule.new
    logger = options[:logger]
    data = yield parse_payload(options[:payload], logger)
    phone = data[:phone]
    the_time = options[:time] || Time.now
    if SmsBlocklistEntry.blocks?(phone)
      logger.error("Received message for blocked sms number: #{data[:phone]}")
      return Success(:blocked)
    end
    if batch_schedule.inside_blackout_hours?(the_time)
      logger.info("Received message during transmission blacklist period for phone: #{data[:phone]}")
      enqueue(batch_schedule, data, the_time)
    else
      send_message_now(data, the_time)
    end
  end

  protected

  def parse_payload(payload, logger)
    parse_result = Try do
      JSON.parse(payload, symbolize_names: true)
    end

    parse_result.or do
      logger.error("Invalid payload: #{payload.inspect}")
      Failure([ :invalid_payload, payload ])
    end
  end

  def enqueue(batch_schedule, data, the_time)
    submitted_at = Time.now
    ContactEvents::ScheduleSmsMessage.perform_at(
      batch_schedule.next_scheduled_time(submitted_at),
      SmsBlocklistEntry.normalize_number(data[:phone]),
      data[:message],
      the_time.iso8601
    )
    Success(:enqueued)
  end

  def send_message_now(data, the_time)
    event_result = event(
        "events.contact_events.sms_message.transmit",
        attributes: {
          phone: SmsBlocklistEntry.normalize_number(data[:phone]),
          message: data[:message],
          submitted_at: the_time.iso8601
        }
    )
    return event_result unless event_result.success?
    Try do
      event_result.success.publish
      :published
    end.to_result
  end
end
