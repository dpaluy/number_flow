# frozen_string_literal: true

require_relative '../test_helper'
require 'rails'
require 'action_controller/railtie'

module NumberFlow
  class SmokeApp < Rails::Application
    config.root = File.expand_path('../..', __dir__)
    config.eager_load = false
    config.secret_key_base = 'x' * 64
    config.hosts << 'www.example.com'
    config.logger = Logger.new($stdout)
  end

  SmokeApp.initialize! unless SmokeApp.initialized?

  class RailsSmokeTest < Minitest::Test
    def test_helper_available_in_view_context
      controller = ActionController::Base.new
      html = controller.view_context.number_flow_tag(42, grouping: true)

      assert_includes html, 'data-controller="number-flow"'
      assert_includes html, 'data-number-flow-grouping-value="true"'
      assert_includes html, 'nf__digit'
    end
  end
end
