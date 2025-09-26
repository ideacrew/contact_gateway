require "rails"

describe Subscribers::SmsBlocklistUpdateProcessSubscriber do
  it "routes correctly" do
    expect([ :amqp, "sms_blocklist.update_process", "trigger" ]).to route_to_subscription(Subscribers::SmsBlocklistUpdateProcessSubscriber, :on_trigger)
  end
end
