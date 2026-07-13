# frozen_string_literal: true

require_relative '../test_helper'

module NumberFlow
  class ControllerContractTest < Minitest::Test
    def test_controller_exposes_update_event_contract
      source = File.read(File.expand_path('../../app/assets/javascripts/number_flow/controller.js', __dir__))

      assert_includes source, 'const UPDATE_EVENT = "number-flow:update"'
      assert_includes source, 'valueValueChanged'
      assert_includes source, 'prefers-reduced-motion'
      assert_includes source, 'grouping'
    end

    def test_controller_supports_decimal_precision
      source = File.read(File.expand_path('../../app/assets/javascripts/number_flow/controller.js', __dir__))

      assert_includes source, 'precision'
      assert_includes source, 'minimumFractionDigits'
      assert_includes source, 'maximumFractionDigits'
    end

    def test_controller_supports_locale
      source = File.read(File.expand_path('../../app/assets/javascripts/number_flow/controller.js', __dir__))

      assert_includes source, 'locale'
      assert_includes source, 'Intl.NumberFormat'
    end
  end
end
