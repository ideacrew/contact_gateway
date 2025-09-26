require "rails_helper"
require "set"

describe HandleSmsBlocklistUpdate do
  before :each do
    SmsBlocklistEntry.where({}).delete
  end

  after :each do
    SmsBlocklistEntry.where({}).delete
  end

  subject do
    described_class.new
  end

  context "with no phone numbers in the db, only 1 page, given a single phone" do
    let(:phone_number) { "1234567890" }

    let(:event) do
      double(
        next_token: nil,
        phone_numbers: [
          phone_number
        ]
      )
    end

    let(:result) do
      subject.call({
        state: Set.new,
        event: event
      })
    end

    it "adds the given phone number and sends a notification" do
      expect(subject).to receive(:event).with(
        "events.sms_blocklist.opted_out",
        { attributes: { phone: SmsBlocklistEntry.normalize_number(phone_number) } }
      ).and_call_original
      expect(result.success?).to be_truthy
      expect(SmsBlocklistEntry.matching_records_for("1234567890").any?).to be_truthy
      expect(result.success.more?).to be_falsey
    end
  end

  context "given:
    - the last page
    - a phone number already in the database, and present on a previous page
    - a phone number already in the database, but not in the result set
    - a phone number in the dataset that isn't in the db
    " do
    let(:phone_number1) { "1234567890" }
    let(:phone_number2) { "1234567891" }
    let(:phone_number3) { "1234567892" }

    let(:event) do
      double(
        next_token: nil,
        phone_numbers: [
          phone_number3
        ]
      )
    end

    let(:result) do
      subject.call({
        state: Set.new([ phone_number1 ]),
        event: event
      })
    end

    before :each do
      SmsBlocklistEntry.create!({
        phone_number: SmsBlocklistEntry.normalize_number(phone_number1)
      })
      SmsBlocklistEntry.create!({
        phone_number: SmsBlocklistEntry.normalize_number(phone_number2)
      })
    end

    it "keeps the first phone number, adds the given phone number, removes the other phone number, and sends notifications" do
      expect(subject).to receive(:event).with(
        "events.sms_blocklist.opted_out",
        { attributes: { phone: SmsBlocklistEntry.normalize_number(phone_number3) } }
      ).and_call_original
      expect(subject).to receive(:event).with(
        "events.sms_blocklist.opted_in",
        { attributes: { phone: SmsBlocklistEntry.normalize_number(phone_number2) } }
      ).and_call_original
      expect(result.success?).to be_truthy
      expect(SmsBlocklistEntry.matching_records_for(phone_number1).any?).to be_truthy
      expect(SmsBlocklistEntry.matching_records_for(phone_number2).any?).to be_falsey
      expect(SmsBlocklistEntry.matching_records_for(phone_number3).any?).to be_truthy
      expect(result.success.more?).to be_falsey
    end
  end

  context "with 1 phone number in the db, another page to follow, given 1 phone that isn't already in the db" do
    let(:phone_number1) { "1234567890" }
    let(:phone_number2) { "1234567899" }

    let(:event) do
      double(
        next_token: "some_token",
        phone_numbers: [
          phone_number2
        ]
      )
    end

    let(:result) do
      subject.call({
        state: Set.new,
        event: event
      })
    end

    before :each do
      SmsBlocklistEntry.create!({
        phone_number: SmsBlocklistEntry.normalize_number(phone_number1)
      })
    end

    it "adds the given phone number and sends notifications" do
      expect(subject).to receive(:event).with(
        "events.sms_blocklist.opted_out",
        { attributes: { phone: SmsBlocklistEntry.normalize_number(phone_number2) } }
      ).and_call_original
      expect(result.success?).to be_truthy
      expect(SmsBlocklistEntry.matching_records_for(phone_number1).any?).to be_truthy
      expect(SmsBlocklistEntry.matching_records_for(phone_number2).any?).to be_truthy
      expect(result.success.more?).to be_truthy
    end
  end
end
