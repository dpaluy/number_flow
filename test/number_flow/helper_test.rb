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

    def test_raises_on_non_numeric_value
      error = assert_raises(ArgumentError) do
        build_view.number_flow_tag('invalid')
      end

      assert_includes error.message, 'numeric value'
    end

    def test_renders_decimal_value
      html = build_view.number_flow_tag(12.34, precision: 2)

      assert_includes html, 'data-number-flow-value-value="12.34"'
      assert_includes html, 'data-number-flow-precision-value="2"'
      assert_includes html, 'aria-label="12.34"'
      assert_includes html, 'nf__separator'
      assert_includes html, 'data-digit="1"'
      assert_includes html, 'data-digit="2"'
    end

    def test_decimal_with_precision_pads_zeros
      html = build_view.number_flow_tag(10, precision: 2)

      assert_includes html, 'aria-label="10.00"'
      assert_includes html, 'data-number-flow-precision-value="2"'
    end

    def test_negative_decimal_value
      html = build_view.number_flow_tag(-3.5, precision: 1)

      assert_includes html, 'data-number-flow-value-value="-3.5"'
      assert_includes html, 'aria-label="-3.5"'
      assert_includes html, 'data-digit="3"'
    end

    def test_integer_regression_byte_identical
      html = build_view.number_flow_tag(1234)

      assert_includes html, 'data-number-flow-value-value="1234"'
      assert_includes html, 'data-number-flow-precision-value="0"'
      assert_includes html, 'aria-label="1234"'
    end

    def test_locale_option_emits_data_attribute
      html = build_view.number_flow_tag(1234.5, precision: 1, locale: 'de-DE', grouping: true)

      assert_includes html, 'data-number-flow-locale-value="de-DE"'
      assert_includes html, 'data-number-flow-precision-value="1"'
      assert_includes html, 'aria-label="1.234,5"'
    end

    def test_locale_en_us_grouping
      html = build_view.number_flow_tag(1234.5, precision: 1, locale: 'en-US', grouping: true)

      assert_includes html, 'data-number-flow-locale-value="en-US"'
      assert_includes html, 'aria-label="1,234.5"'
    end

    def test_locale_nil_omits_data_attribute
      html = build_view.number_flow_tag(1234)

      refute_includes html, 'data-number-flow-locale-value'
    end

    def test_nine_nine_nine_rollover_format
      html = build_view.number_flow_tag(9.99, precision: 2)

      assert_includes html, 'aria-label="9.99"'
      assert_includes html, 'data-digit="9"'
    end
  end
end
