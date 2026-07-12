# frozen_string_literal: true

require_relative '../test_helper'

module NumberFlow
  class ComponentTest < Minitest::Test
    include NumberFlowTestSupport

    def test_component_defined_when_view_component_present
      # view_component is in the test group, so it should be loaded.
      assert defined?(::ViewComponent), 'view_component gem should be present in test'
      assert defined?(NumberFlow::Component), 'NumberFlow::Component should be defined'
    end

    def test_component_renders_same_markup_as_helper
      helper_html = build_view.number_flow_tag(42, precision: 2)

      component = NumberFlow::Component.new(value: 42, precision: 2)
      component_html = component.call

      assert_equal helper_html, component_html
    end

    def test_component_supports_all_options
      helper_html = build_view.number_flow_tag(
        12.34, precision: 2, locale: 'de-DE', grouping: true, duration: 800
      )

      component = NumberFlow::Component.new(
        value: 12.34, precision: 2, locale: 'de-DE', grouping: true, duration: 800
      )
      component_html = component.call

      assert_equal helper_html, component_html
    end

    def test_component_works_with_integer
      helper_html = build_view.number_flow_tag(1234)

      component = NumberFlow::Component.new(value: 1234)
      assert_equal helper_html, component.call
    end
  end
end
