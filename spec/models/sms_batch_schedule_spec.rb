require "rails_helper"

describe SmsBatchSchedule, "when the feature is disabled" do
  let(:batch_feature) do
    double(enabled?: false)
  end

  before :each do
    allow(ContactGatewayRegistry).to receive(:[]).with(:sms_batching).and_return batch_feature
  end

  subject { described_class.new }

  it "is never inside a blackout period" do
    expect(subject.inside_blackout_hours?(Time.now)).to be_falsey
  end
end
