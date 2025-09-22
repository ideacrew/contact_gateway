module Publishers
  class SmsBlocklistPublisher
    include ::EventSource::Publisher[arn: "sms_blocklist.update"]
    register_event "requested"
  end
end
