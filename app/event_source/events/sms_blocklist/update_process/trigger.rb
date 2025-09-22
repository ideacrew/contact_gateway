module Events
  module SmsBlocklist
    module UpdateProcess
      class Trigger < EventSource::Event
        publisher_path "publishers.sms_blocklist_update_process_publisher"
      end
    end
  end
end
