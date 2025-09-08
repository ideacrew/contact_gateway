require "rails_helper"
require "event_source/rspec/event_routing_matchers"

describe Events::ContactEvents::SmsMessage::Transmit do
  include EventSource::Command

  it "routes correctly" do
    published_event = event("events.contact_events.sms_message.transmit", attributes: {})
    expect(published_event).to route_to_publisher(:arn, "contact_gateway.sms_message.transmit")
  end
end
