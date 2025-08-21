class SmsBatchSchedule
  def initialize
    @feature = ContactGatewayRegistry[:sms_batching]
    @batch_capture_start = @feature.setting(:sms_batch_capture_start).item
    @batch_capture_end = @feature.setting(:sms_batch_capture_end).item
    @batch_timezone = @feature.setting(:sms_batch_timezone).item
    @batch_capture_begin_hour = @batch_capture_start.to_i
    @batch_capture_cutoff_hour = @batch_capture_end.to_i
  end

  def inside_capture_hours?(the_time)
    adj_time = the_time
    adj_time.hour >= @batch_capture_begin_hour || adj_time.hour <= @batch_capture_cutoff_hour
  end
end
