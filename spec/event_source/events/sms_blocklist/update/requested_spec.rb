require "rails_helper"

describe Events::SmsBlocklist::Update::Requested do
  include EventSource::Command

  it "routes correctly when published" do
    published_event = event("events.sms_blocklist.update.requested", attributes: {})
    expect(published_event).to route_to_publisher(:arn, "sms_blocklist.update.requested")
  end
end
