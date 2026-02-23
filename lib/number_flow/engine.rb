# frozen_string_literal: true

begin
  require 'active_support/core_ext/module/delegation'
  require 'rails/engine'
rescue LoadError
  # Rails is not available in this runtime.
end

module NumberFlow
  if defined?(Rails)
    class Engine < ::Rails::Engine
      initializer 'number_flow.action_view' do
        ActiveSupport.on_load(:action_view) do
          include NumberFlow::Helper
        end
      end

      initializer 'number_flow.assets.precompile' do |app|
        next unless app.config.respond_to?(:assets)

        app.config.assets.precompile += %w[number_flow.css number_flow/controller.js]
      end
    end
  end
end
