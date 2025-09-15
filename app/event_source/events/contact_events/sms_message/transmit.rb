module Events
  module ContactEvents
    module SmsMessage
      class Transmit < EventSource::Event
        publisher_path "publishers.contact_events.sms_message_publisher"
      end
    end
  end
end
