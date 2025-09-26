require "set"

module Subscribers
  # Subscriber will receive Enterprise requests like date change
  class SmsBlocklistSubscriber
    include ::EventSource::Subscriber[arn: "sms_blocklist.update"]

    subscribe(:on_requested) do |state, event|
      current_state = state || Set.new
      result = HandleSmsBlocklistUpdate.new.call({
        state: current_state,
        event: event
      })
      if result.success?
        result.value!
      else
        logger.error result.failure
        EventSource::Paginator.finished
      end
    end
  end
end
