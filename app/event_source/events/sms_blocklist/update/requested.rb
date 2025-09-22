module Events
  module SmsBlocklist
    module Update
      class Requested < EventSource::Event
        publisher_path "publishers.sms_blocklist_publisher"
      end
    end
  end
end
