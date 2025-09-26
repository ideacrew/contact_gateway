require "rails_helper"

describe TransmitSmsMessage, "given a valid, unblocked message, not during a blackout period" do
  let(:result) { described_class.new.call(params) }

  let(:phone_number) { "1234567890" }

  let(:data) do
    {
      phone: phone_number,
      message: "A test message"
    }
  end

  let(:params) do
    {
      logger: Rails.logger,
      payload: JSON.dump(data),
      time: the_time
    }
  end

  let(:the_time) { Date.today.to_time }

  let(:batch_schedule) do
    instance_double(SmsBatchSchedule)
  end

  before :each do
    allow(SmsBatchSchedule).to receive(:new).and_return(batch_schedule)
    allow(batch_schedule).to receive(:inside_blackout_hours?).with(the_time).and_return false
    allow(SmsBlocklistEntry).to receive(:blocks?).with(phone_number).and_return false
  end

  let(:expected_transmission_properties) do
    {
      message: "A test message",
      message_attributes: { "submitted_at" => { data_type: "String", string_value: the_time.iso8601 } },
      phone_number: "+11234567890"
    }
  end

  it "transmits immediately" do
    expect_any_instance_of(Aws::SNS::Client).to receive(:publish).with(expected_transmission_properties)
    expect(result.success?).to be_truthy
    expect(result.success).to eq :published
  end
end

describe TransmitSmsMessage, "given a valid, unblocked message, during a blackout period" do
  let(:result) { described_class.new.call(params) }

  let(:phone_number) { "1234567890" }

  let(:data) do
    {
      phone: phone_number,
      message: "A test message"
    }
  end

  let(:params) do
    {
      logger: Rails.logger,
      payload: JSON.dump(data),
      time: the_time
    }
  end

  let(:the_time) { Date.today.to_time }

  let(:batch_schedule) do
    instance_double(SmsBatchSchedule)
  end

  before :each do
    allow(SmsBatchSchedule).to receive(:new).and_return(batch_schedule)
    allow(batch_schedule).to receive(:inside_blackout_hours?).with(the_time).and_return true
    allow(batch_schedule).to receive(:next_scheduled_time).and_return the_time
    allow(SmsBlocklistEntry).to receive(:blocks?).with(phone_number).and_return false
  end

  it "enqueues the job" do
    expect(result.success?).to be_truthy
    expect(result.success).to eq :enqueued
  end
end

describe TransmitSmsMessage, "given a valid, blocked message" do
  let(:result) { described_class.new.call(params) }

  let(:phone_number) { "1234567890" }

  let(:data) do
    {
      phone: phone_number,
      message: "A test message"
    }
  end

  let(:params) do
    {
      logger: Rails.logger,
      payload: JSON.dump(data),
      time: the_time
    }
  end

  let(:the_time) { Date.today.to_time }

  let(:batch_schedule) do
    instance_double(SmsBatchSchedule)
  end

  before :each do
    allow(SmsBatchSchedule).to receive(:new).and_return(batch_schedule)
    allow(SmsBlocklistEntry).to receive(:blocks?).with(phone_number).and_return true
  end

  it "is blocked" do
    expect(result.success?).to be_truthy
    expect(result.success).to eq :blocked
  end
end
