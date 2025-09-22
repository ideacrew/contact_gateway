require "rails_helper"

describe Events::SmsBlocklist::UpdateProcess::Trigger do
  include EventSource::Command

  it "routes correctly when published" do
    published_event = event("events.sms_blocklist.update_process.trigger", attributes: {})
    expect(published_event).to route_to_publisher(:amqp, "sms_blocklist.update_process.trigger")
  end
end
