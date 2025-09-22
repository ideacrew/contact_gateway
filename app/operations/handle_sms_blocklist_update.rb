# Handle the list of blocked SMS numbers returned by the API, using pagination
class HandleSmsBlocklistUpdate
  include Dry::Monads[:result, :do, :try]
  include EventSource::Command

  def call(options = {})
    state, event = yield validate_params(options)
    if event.next_token
      p_numbers = event.phone_numbers
      new_state = state.merge(p_numbers)
      yield add_numbers(p_numbers)
      Success(EventSource::Paginator.continue(new_state, { next_token: event.next_token }))
    else
      p_numbers = event.phone_numbers
      new_state = state.merge(p_numbers)
      yield add_numbers(p_numbers)
      yield remove_missing(new_state)
      Success(EventSource::Paginator.finished)
    end
  end

  protected

  def validate_params(options)
    return Failure(:no_event_provided) unless options[:event]
    return Failure(:no_state_provided) unless options[:state]
    Success([ options[:state], options[:event] ])
  end

  def add_numbers(phone_numbers)
    Try do
      phone_numbers.each do |pn|
        unless SmsBlocklistEntry.matching_records_for(pn).any?
          SmsBlocklistEntry.create!({
            phone_number: SmsBlocklistEntry.normalize_number(pn)
          })
          event("events.sms_blocklist.opted_out", attributes: {
            phone: SmsBlocklistEntry.normalize_number(pn)
          }).success.publish
        end
      end
      :ok
    end.to_result
  end

  def remove_missing(full_set)
    Try do
      SmsBlocklistEntry.where({}).order_by({ created_at: 1 }).no_timeout.each do |record|
        search_values = SmsBlocklistEntry.search_values(record.phone_number)
        unless search_values.any? { |sv| full_set.include?(sv) }
          record.destroy!
          event("events.sms_blocklist.opted_in", attributes: {
            phone: SmsBlocklistEntry.normalize_number(record.phone_number)
          }).success.publish
        end
        full_set.subtract(search_values)
      end
      :ok
    end.to_result
  end
end
