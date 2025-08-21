# frozen_string_literal: true

ContactGatewayRegistry = ResourceRegistry::Registry.new

ContactGatewayRegistry.configure do |config|
  config.name       = :contact_gateway
  config.created_at = DateTime.now
  config.load_path  = Rails.root.join("config", "features").to_s
end
