# frozen_string_literal: true

# Test support for browser-based system tests using Cuprite (headless Chrome).
# This file is only required when system tests are active (RUN_SYSTEM_TESTS=true).

require 'capybara'
require 'capybara/dsl'

begin
  require 'capybara/cuprite'

  Capybara.register_driver(:number_flow_cuprite) do |app|
    Capybara::Cuprite::Driver.new(app, headless: true, js_errors: true, window_size: [1280, 720])
  end

  Capybara.default_driver = :number_flow_cuprite
  Capybara.javascript_driver = :number_flow_cuprite
  Capybara.current_driver = :number_flow_cuprite
rescue LoadError
  # cuprite not available — system tests will be skipped.
end

Capybara.server = :webrick
Capybara.server_host = '127.0.0.1'
Capybara.default_max_wait_time = 5

module NumberFlow
  module SystemTestHelper
    CONTROLLER_JS_PATH = File.expand_path('../../app/assets/javascripts/number_flow/controller.js', __dir__)
    CSS_PATH = File.expand_path('../../app/assets/stylesheets/number_flow.css', __dir__)
    STIMULUS_PATH = File.expand_path('support/stimulus.js', __dir__)

    def build_html_page(initial_html: '')
      css = File.read(CSS_PATH)
      stimulus_js = File.read(STIMULUS_PATH)

      <<~HTML
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <title>NumberFlow System Test</title>
          <style>#{css}</style>
        </head>
        <body>
          <div id="container">#{initial_html}</div>
          <script>#{stimulus_js}</script>
          <script>
            var StimulusApp = Stimulus.Application.start();
            #{register_controller_js}
          </script>
        </body>
        </html>
      HTML
    end

    private

    def register_controller_js
      controller_source = File.read(CONTROLLER_JS_PATH)
      # Extract the class body (remove ESM import lines)
      class_body = controller_source.gsub(/^import .*/, '').strip
      # Replace ESM export syntax for inline browser use
      class_body = class_body.sub(/^export default class extends Controller/,
                                  'class NumberFlowController extends Stimulus.Controller')

      <<-JS
        #{class_body}
        StimulusApp.register("number-flow", NumberFlowController);
        window.StimulusApp = StimulusApp;
      JS
    end

    def build_number_flow_markup(value, **options)
      precision = options.fetch(:precision, 0)
      duration = options.fetch(:duration, 400)
      easing = options.fetch(:easing, 'cubic-bezier(0.2, 0, 0, 1)')
      stagger = options.fetch(:stagger, 20)
      grouping = options.fetch(:grouping, false)
      locale = options[:locale]

      data_attrs = [
        'data-controller="number-flow"',
        "data-number-flow-value-value=\"#{value}\"",
        "data-number-flow-duration-value=\"#{duration}\"",
        "data-number-flow-easing-value=\"#{easing}\"",
        "data-number-flow-stagger-value=\"#{stagger}\"",
        "data-number-flow-grouping-value=\"#{grouping}\"",
        "data-number-flow-precision-value=\"#{precision}\""
      ]
      data_attrs << "data-number-flow-locale-value=\"#{locale}\"" if locale

      # Build digit spans
      formatted = format_for_test(value, precision, grouping, locale)
      inner = formatted.chars.map do |char|
        if char.match?(/\d/)
          build_digit_span_html(char.to_i)
        else
          %(<span class="nf__separator" aria-hidden="true">#{char}</span>)
        end
      end.join

      %(<span class="nf" role="status" aria-live="polite" aria-label="#{formatted}" #{data_attrs.join(' ')}>#{inner}</span>)
    end

    def format_for_test(value, precision, grouping, locale)
      sign = value.negative? ? '-' : ''
      abs = value.abs
      decimal_sep = locale && !locale.start_with?('en') ? ',' : '.'
      group_sep = locale && !locale.start_with?('en') ? '.' : ','

      if precision.positive?
        int_part = Integer(abs.floor)
        fraction = format('%.0f', (abs - int_part) * (10**precision)).rjust(precision, '0')
        int_str = grouping ? int_part.to_s.reverse.scan(/.{1,3}/).join(group_sep).reverse : int_part.to_s
        "#{sign}#{int_str}#{decimal_sep}#{fraction}"
      else
        int_str = Integer(abs).to_s
        int_str = int_str.reverse.scan(/.{1,3}/).join(group_sep).reverse if grouping
        "#{sign}#{int_str}"
      end
    end

    def build_digit_span_html(digit)
      cells = (0..9).map { |v| %(<span class="nf__cell" aria-hidden="true">#{v}</span>) }.join
      %(<span class="nf__digit" data-digit="#{digit}"><span class="nf__track" data-to-digit="#{digit}" style="--nf-current-digit: #{digit}; --nf-from-digit: #{digit}; --nf-to-digit: #{digit};">#{cells}</span></span>)
    end
  end
end
