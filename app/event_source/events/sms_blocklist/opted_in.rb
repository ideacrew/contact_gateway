module Events
  module SmsBlocklist
    class OptedIn < EventSource::Event
      publisher_path "publishers.contact_events.sms_communication_publisher"
    end
  end
end
