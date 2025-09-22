module Publishers
  module ContactEvents
    class SmsCommunicationPublisher
      include ::EventSource::Publisher[amqp: "contact_events.sms_communication"]

      register_event "opted_out"
      register_event "opted_in"
    end
  end
end
