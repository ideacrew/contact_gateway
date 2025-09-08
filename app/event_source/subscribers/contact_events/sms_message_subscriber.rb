module Subscribers
  module ContactEvents
    class SmsMessageSubscriber
      include EventSource::Logging
      include ::EventSource::Subscriber[amqp: "contact_events.sms_message"]

      subscribe(:on_transmit) do |delivery_info, metadata, response|
        ::TransmitSmsMessage.new.call(
          {
            payload: response,
            logger: Rails.logger.tagged(self.class.name.to_s)
          }
        )
        ack(delivery_info.delivery_tag)
      end
    end
  end
end
