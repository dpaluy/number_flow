# frozen_string_literal: true

require_relative '../test_helper'

# Gate system tests behind an env var so they don't run in environments
# without Chrome (e.g., basic CI or local quick-test runs).
if ENV['RUN_SYSTEM_TESTS'] == 'true'
  require_relative 'test_support'
  require 'capybara/minitest'

  module NumberFlow
    class AnimationSystemTest < Minitest::Test
      include Capybara::DSL
      include Capybara::Minitest::Assertions
      include NumberFlow::SystemTestHelper

      def teardown
        Capybara.reset_sessions!
      end

      def setup_browser_page(html_content)
        Capybara.current_driver = :number_flow_cuprite
        Capybara.app = lambda do |_env|
          [200, { 'content-type' => 'text/html' }, [html_content]]
        end
        visit '/'
      end

      def dispatch_update(value)
        page.execute_script(<<~JS)
          const el = document.querySelector('[data-controller="number-flow"]');
          el.dispatchEvent(new CustomEvent("number-flow:update", { detail: { value: #{value} } }));
        JS
      end

      def wait_for_stimulus_connect
        # Wait for Stimulus to be loaded and controller to have connected
        sleep 0.5
      end

      # Acceptance: A browser-backed test dispatches number-flow:update
      # and verifies final rendered digits
      def test_update_animates_to_final_digits
        html = build_html_page(initial_html: build_number_flow_markup(0))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        # Verify initial state shows digit 0
        initial_digits = page.all('.nf__digit[data-digit]')
        assert_equal 1, initial_digits.length, 'Should start with one digit (0)'

        # Dispatch update event to change value to 5
        dispatch_update(5)

        # Give the animation a moment to render
        sleep 0.3

        # Verify final rendered digits show 5
        digits = page.all('.nf__digit[data-digit]')
        assert_equal 1, digits.length
        assert_equal '5', digits.first['data-digit']

        # Verify the aria-label is updated
        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '5', label
      end

      def test_update_to_multi_digit_value
        html = build_html_page(initial_html: build_number_flow_markup(0))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        dispatch_update(123)

        sleep 0.3

        digits = page.all('.nf__digit[data-digit]')
        assert_equal 3, digits.length
        digit_values = digits.map { |d| d['data-digit'] }
        assert_equal %w[1 2 3], digit_values

        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '123', label
      end

      def test_decimal_update_and_final_digits
        html = build_html_page(initial_html: build_number_flow_markup(0, precision: 2))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        dispatch_update(12.34)

        sleep 0.3

        digits = page.all('.nf__digit[data-digit]')
        digit_values = digits.map { |d| d['data-digit'] }
        assert_equal %w[1 2 3 4], digit_values, 'Should show digits 1,2,3,4 for 12.34'

        separators = page.all('.nf__separator')
        assert(separators.any? { |s| s.text == '.' }, 'Should have a decimal separator')

        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '12.34', label
      end

      def test_rollover_from_nine_nine_nine
        html = build_html_page(initial_html: build_number_flow_markup(9.99, precision: 2))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        dispatch_update(10.00)

        sleep 0.3

        digits = page.all('.nf__digit[data-digit]')
        digit_values = digits.map { |d| d['data-digit'] }
        assert_equal %w[1 0 0 0], digit_values, '9.99 -> 10.00 rollover'

        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '10.00', label
      end

      # Acceptance: Reduced-motion scenario is covered
      def test_reduced_motion_skips_animation_track_class
        html = build_html_page(initial_html: build_number_flow_markup(0))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        # Override the reduced motion media query to return true (reduced)
        page.execute_script(<<~JS)
          const controller = window.StimulusApp.controllers.find(c =>
            c.element.hasAttribute('data-controller') &&
            c.element.getAttribute('data-controller').includes('number-flow')
          );
          if (controller) {
            controller.reducedMotionMedia = { matches: true };
          }
        JS

        dispatch_update(7)

        sleep 0.2

        # With reduced motion, the track should NOT have the animated class
        animated_tracks = page.all('.nf__track--animated')
        assert_equal 0, animated_tracks.length,
                     'No animated tracks when prefers-reduced-motion: reduce'

        # The final digit should still be correct
        digits = page.all('.nf__digit[data-digit]')
        assert_equal '7', digits.last['data-digit']
      end

      def test_negative_value_animation
        html = build_html_page(initial_html: build_number_flow_markup(0))
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        dispatch_update(-42)

        sleep 0.3

        digits = page.all('.nf__digit[data-digit]')
        digit_values = digits.map { |d| d['data-digit'] }
        assert_equal %w[4 2], digit_values

        separators = page.all('.nf__separator')
        assert(separators.any? { |s| s.text == '-' }, 'Should have a negative sign separator')

        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '-42', label
      end

      def test_locale_de_de_formatting
        html = build_html_page(
          initial_html: build_number_flow_markup(1234.5, precision: 1, grouping: true, locale: 'de-DE')
        )
        setup_browser_page(html)

        page.assert_selector('[data-controller="number-flow"]', visible: true)
        wait_for_stimulus_connect

        # After Stimulus connect, JS re-renders with Intl.NumberFormat
        sleep 0.3

        label = page.find('[data-controller="number-flow"]')[:'aria-label']
        assert_equal '1.234,5', label, 'de-DE locale should format as 1.234,5'
      end
    end
  end
else
  warn '[number_flow] Skipping system tests (set RUN_SYSTEM_TESTS=true to enable)'
end
