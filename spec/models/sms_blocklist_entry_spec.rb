require "rails_helper"

describe SmsBlocklistEntry, "given nothing" do
  let(:subject) { described_class.new }

  it "is invalid" do
    expect(subject.valid?).to be_falsey
  end
end

describe SmsBlocklistEntry, "given a phone number with no country code" do
  let(:number) { "4432341234" }

  it "returns a normalized number" do
    expect(described_class.normalize_number(number)).to eq "+14432341234"
  end

  it "returns correct options for search matching" do
    expect(described_class.search_values(number)).to eq [ "4432341234", "+14432341234" ]
  end

  it "is blocked when it matched database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([ 1 ])
    expect(SmsBlocklistEntry.blocks?(number)).to be_truthy
  end

  it "not blocked with no matching database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([])
    expect(SmsBlocklistEntry.blocks?(number)).to be_falsey
  end
end

describe SmsBlocklistEntry, "given a phone number with a country code" do
  let(:number) { "+14432341234" }

  it "returns a normalized number" do
    expect(described_class.normalize_number(number)).to eq "+14432341234"
  end

  it "returns correct options for search matching" do
    expect(described_class.search_values(number)).to eq [ "4432341234", "+14432341234" ]
  end

  it "is blocked when it matched database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([ 1 ])
    expect(SmsBlocklistEntry.blocks?(number)).to be_truthy
  end

  it "not blocked with no matching database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([])
    expect(SmsBlocklistEntry.blocks?(number)).to be_falsey
  end
end

describe SmsBlocklistEntry, "given a phone number with a country code, but no +" do
  let(:number) { "14432341234" }

  it "returns a normalized number" do
    expect(described_class.normalize_number(number)).to eq "+14432341234"
  end

  it "returns correct options for search matching" do
    expect(described_class.search_values(number)).to eq [ "4432341234", "+14432341234" ]
  end

  it "is blocked when it matched database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([ 1 ])
    expect(SmsBlocklistEntry.blocks?(number)).to be_truthy
  end

  it "not blocked with no matching database records" do
    allow(SmsBlocklistEntry).to receive(:where).with({ phone_number: { "$in" => [ "4432341234", "+14432341234" ] } }).and_return([])
    expect(SmsBlocklistEntry.blocks?(number)).to be_falsey
  end
end
