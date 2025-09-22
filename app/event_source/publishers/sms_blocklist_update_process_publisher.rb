module Publishers
  class SmsBlocklistUpdateProcessPublisher
    include ::EventSource::Publisher[amqp: "sms_blocklist.update_process"]
    register_event "trigger"
  end
end
