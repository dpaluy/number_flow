# frozen_string_literal: true

require_relative '../test_helper'

module NumberFlow
  class HelperTest < Minitest::Test
    include NumberFlowTestSupport

    def test_renders_default_markup
      html = build_view.number_flow_tag(1234)

      assert_includes html, 'class="nf"'
      assert_includes html, 'data-controller="number-flow"'
      assert_includes html, 'data-number-flow-value-value="1234"'
      assert_includes html, 'data-number-flow-duration-value="400"'
      assert_includes html, 'aria-label="1234"'
    end

    def test_renders_grouping_and_custom_html_options
      html = build_view.number_flow_tag(
        1_234_567,
        class: 'kpi',
        grouping: true,
        data: { source_name: 'dashboard' }
      )

      assert_includes html, 'class="nf kpi"'
      assert_includes html, 'data-number-flow-grouping-value="true"'
      assert_includes html, 'data-source-name="dashboard"'
      assert_includes html, 'nf__separator'
      assert_includes html, ','
    end

    def test_grouping_false_emits_false_data_attribute
      html = build_view.number_flow_tag(1_234_567, grouping: false)

      assert_includes html, 'data-number-flow-grouping-value="false"'
      refute_includes html, 'nf__separator'
    end

    def test_renders_negative_number
      html = build_view.number_flow_tag(-42)

      assert_includes html, 'data-number-flow-value-value="-42"'
      assert_includes html, 'aria-label="-42"'
      assert_includes html, 'nf__separator'
    end

    def test_renders_zero
      html = build_view.number_flow_tag(0)

      assert_includes html, 'data-number-flow-value-value="0"'
      assert_includes html, 'aria-label="0"'
    end

    def test_custom_duration_easing_stagger
      html = build_view.number_flow_tag(99, duration: 800, easing: 'ease-out', stagger: 50)

      assert_includes html, 'data-number-flow-duration-value="800"'
      assert_includes html, 'data-number-flow-easing-value="ease-out"'
      assert_includes html, 'data-number-flow-stagger-value="50"'
    end

    def test_aria_label_override
      html = build_view.number_flow_tag(500, aria_label: 'Total users')

      assert_includes html, 'aria-label="Total users"'
    end

    def test_id_option
      html = build_view.number_flow_tag(7, id: 'counter')

      assert_includes html, 'id="counter"'
    end

    def test_raises_on_non_integer_value
      error = assert_raises(ArgumentError) do
        build_view.number_flow_tag('invalid')
      end

      assert_includes error.message, 'integer-compatible'
    end
  end
end
