# frozen_string_literal: true

EventSource.configure do |config|
  config.app_name = :contact_gateway
  config.pub_sub_root = Pathname.pwd.join("app", "event_source")
  config.server_key = ENV["RAILS_ENV"] || Rails.env.to_sym
  config.protocols = %w[amqp arn]

  config.servers do |server|
    server.amqp do |rabbitmq|
      rabbitmq.ref = "amqp://rabbitmq:5672/event_source"
      rabbitmq.host = ENV["RABBITMQ_HOST"] || "amqp://localhost"
      rabbitmq.vhost = ENV["RABBITMQ_VHOST"] || "event_source"
      rabbitmq.port = ENV["RABBITMQ_PORT"] || "5672"
      rabbitmq.url = ENV["RABBITMQ_URL"] || "amqp://localhost:5672/event_source"
      rabbitmq.user_name = ENV["RABBITMQ_USERNAME"] || "guest"
      rabbitmq.password = ENV["RABBITMQ_PASSWORD"] || "guest"
    end
  end

  config.servers do |server|
    server.arn do |arn|
      arn.url = "arn:aws:sns:{region}:contact_gateway_sms_transmission_account:{options}"
      arn.variables do |v|
        v.region = ENV["CONTACT_GATEWAY_AWS_SNS_SMS_REGION"] || "us-east-1"
      end
      arn.security do |s|
        s.access_key_id = ENV["CONTACT_GATEWAY_AWS_SNS_SMS_ACCESS_KEY_ID"] || "access_key"
        s.secret_access_key = ENV["CONTACT_GATEWAY_AWS_SNS_SMS_SECRET_ACCESS_KEY"] || "secret_access_key"
        s.endpoint_url = ENV["CONTACT_GATEWAY_LOCALSTACK_URL"] unless ENV["CONTACT_GATEWAY_LOCALSTACK_URL"].blank?
      end
    end
  end

  async_api_resources = ::AcaEntities.async_api_config_find_by_service_name({ protocol: :amqp, service_name: "contact_gateway" }).success
  async_api_resources += ::AcaEntities.async_api_config_find_by_service_name({ protocol: :arn, service_name: "contact_gateway" }).success
  config.async_api_schemas = async_api_resources.collect { |resource| EventSource.build_async_api_resource(resource) }
end
