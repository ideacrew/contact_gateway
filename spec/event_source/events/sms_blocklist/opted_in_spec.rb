require "rails_helper"

describe Events::SmsBlocklist::OptedIn do
  include EventSource::Command

  it "routes correctly when published" do
    published_event = event("events.sms_blocklist.opted_in", attributes: { phone: "1234567890" })
    expect(published_event).to route_to_publisher(:amqp, "contact_events.sms_communication.opted_in")
  end
end
