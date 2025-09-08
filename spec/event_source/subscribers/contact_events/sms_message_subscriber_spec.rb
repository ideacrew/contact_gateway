require "rails_helper"
require "event_source/rspec/event_routing_matchers"

describe Subscribers::ContactEvents::SmsMessageSubscriber do
  it "routes correctly" do
    expect([ :amqp, "contact_events.sms_message", "transmit" ]).to route_to_subscription(Subscribers::ContactEvents::SmsMessageSubscriber, :on_transmit)
  end
end
