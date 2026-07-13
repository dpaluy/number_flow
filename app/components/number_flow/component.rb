# frozen_string_literal: true

require 'number_flow/helper'

begin
  require 'view_component'
rescue LoadError
  # ViewComponent is not installed — Component is not defined.
end

module NumberFlow
  # Optional ViewComponent wrapper around the +number_flow_tag+ helper.
  # Only defined when the +view_component+ gem is available, so the gem
  # never forces a hard dependency.
  if defined?(::ViewComponent)
    class Component < ::ViewComponent::Base
      include NumberFlow::Helper

      def initialize(value:, **options)
        @value = value
        @options = options
        super()
      end

      def call
        number_flow_tag(@value, **@options)
      end
    end
  end
end
