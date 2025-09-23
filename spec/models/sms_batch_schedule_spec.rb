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

describe SmsBatchSchedule, "when the feature is enabled" do
  let(:item) do
    Proc.new do |value|
      double(
        item: value
      )
    end
  end

  let(:batch_feature) do
    double(
      enabled?: true
    )
  end

  before :each do
    allow(ContactGatewayRegistry).to receive(:[]).with(:sms_batching).and_return batch_feature
    allow(batch_feature).to receive(:setting).with(:sms_batch_capture_start).and_return(item.("21"))
    allow(batch_feature).to receive(:setting).with(:sms_batch_capture_end).and_return(item.("07"))
    allow(batch_feature).to receive(:setting).with(:sms_batch_timezone).and_return(item.("America/New_York"))
  end

  subject { described_class.new }

  it "is not inside a blackout period at noon" do
    expect(subject.inside_blackout_hours?(Time.now.noon)).to be_falsey
  end

  it "is inside a blackout period at 1 am" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 1)
    expect(subject.inside_blackout_hours?(the_time)).to be_truthy
  end

  it "is inside a blackout period at 10 pm" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 22)
    expect(subject.inside_blackout_hours?(the_time)).to be_truthy
  end

  it "is inside a blackout period at 9 pm" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 21)
    expect(subject.inside_blackout_hours?(the_time)).to be_truthy
  end

  it "is not inside a blackout period at 7 am" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 7)
    expect(subject.inside_blackout_hours?(the_time)).to be_falsey
  end

  it "is not inside a blackout period at 7:12 am" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 7).change(minute: 12)
    expect(subject.inside_blackout_hours?(the_time)).to be_falsey
  end

  it "is not inside a blackout period at 8:59 pm" do
    the_time = Time.now.noon.in_time_zone("America/New_York").change(hour: 20).change(minute: 59)
    expect(subject.inside_blackout_hours?(the_time)).to be_falsey
  end

  it "provides correct the next scheduled time for delivery" do
    expected_time = Time.now.noon.in_time_zone("America/New_York").advance(days: 1).change(hour: 7)
    expect(subject.next_scheduled_time(Time.now.noon)).to eq expected_time
  end
end
