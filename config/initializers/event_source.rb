# frozen_string_literal: true

EventSource.configure do |config|
  config.app_name = :contact_gateway
  config.pub_sub_root = Pathname.pwd.join("app", "event_source")
  config.server_key = ENV["RAILS_ENV"] || Rails.env.to_sym
  config.protocols = %w[amqp]
end
