class SmsBatchSchedule
  def initialize
    @feature = ContactGatewayRegistry[:sms_batching]
    return unless @feature.enabled?
    @batch_capture_start = @feature.setting(:sms_batch_capture_start).item
    @batch_capture_end = @feature.setting(:sms_batch_capture_end).item
    batch_timezone_string = @feature.setting(:sms_batch_timezone).item
    @batch_timezone = ActiveSupport::TimeZone.new(batch_timezone_string)
    @batch_capture_begin_hour = @batch_capture_start.to_i
    @batch_capture_cutoff_hour = @batch_capture_end.to_i
  end

  def next_scheduled_time(the_time)
    adj_time = the_time.in_time_zone(@batch_timezone)
    tomorrow = adj_time.advance(days: 1)
    tomorrow.change(@batch_capture_cutoff_hour).utc
  end

  def inside_blackout_hours?(the_time)
    return false unless @feature.enabled?
    adj_time = the_time.in_time_zone(@batch_timezone)
    adj_time.hour >= @batch_capture_begin_hour || adj_time.hour <= @batch_capture_cutoff_hour
  end
end
