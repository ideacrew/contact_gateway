module Subscribers
  class SmsBlocklistUpdateProcessSubscriber
    include EventSource::Logging
    include ::EventSource::Subscriber[amqp: "sms_blocklist.update_process"]

    subscribe(:on_trigger) do |delivery_info, metadata, response|
      ::ContactEvents::UpdateSmsBlocklist.perform_async
      ack(delivery_info.delivery_tag)
    end
  end
end
