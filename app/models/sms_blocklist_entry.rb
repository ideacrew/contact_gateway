class SmsBlocklistEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :phone_number, type: String

  validates_presence_of :phone_number, allow_blank: false

  def self.search_values(number)
    parsed_number = Phonelib.parse(number)
    [ parsed_number.e164.delete_prefix("+" + parsed_number.country_code), parsed_number.e164 ]
  end

  def self.normalize_number(number)
    Phonelib.parse(number).e164
  end

  def self.matching_records_for(number)
    search_array = search_values(number)
    SmsBlocklistEntry.where({ phone_number: { "$in" => search_array } })
  end

  def self.blocks?(number)
    matching_records_for(number).any?
  end
end
