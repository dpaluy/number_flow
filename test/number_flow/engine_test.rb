# frozen_string_literal: true

require_relative '../test_helper'
require 'rails'

module NumberFlow
  class EngineTest < Minitest::Test
    def test_engine_is_defined_when_rails_is_loaded
      assert defined?(NumberFlow::Engine)
      assert_equal Rails::Engine, NumberFlow::Engine.superclass
    end
  end
end
