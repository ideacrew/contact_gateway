module Publishers
  module ContactEvents
    class SmsMessagePublisher
      include ::EventSource::Publisher[arn: "contact_gateway.sms_message"]

      register_event "transmit"
    end
  end
end
