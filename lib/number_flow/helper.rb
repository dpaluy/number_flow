# frozen_string_literal: true

module NumberFlow
  # View helper that renders number-flow compatible markup.
  module Helper
    DEFAULT_DURATION = 400
    DEFAULT_EASING = 'cubic-bezier(0.2, 0, 0, 1)'
    DEFAULT_STAGGER = 20

    def number_flow_tag(
      value,
      id: nil,
      duration: DEFAULT_DURATION,
      easing: DEFAULT_EASING,
      stagger: DEFAULT_STAGGER,
      grouping: false,
      precision: 0,
      locale: nil,
      aria_label: nil,
      data: {},
      **html_options
    )
      normalized_value = coerce_number(value)
      formatted_value = format_number(normalized_value, precision: precision, grouping: grouping, locale: locale)
      css_class = html_options.delete(:class)
      extra_data = html_options.delete(:data)

      root_options = {
        id: id,
        role: 'status',
        class: ['nf', css_class].compact.join(' '),
        aria: {
          live: 'polite',
          label: aria_label || formatted_value
        },
        data: merged_data_attributes(
          {
            controller: 'number-flow',
            number_flow_value_value: normalized_value,
            number_flow_duration_value: Integer(duration),
            number_flow_easing_value: easing.to_s,
            number_flow_stagger_value: Integer(stagger),
            number_flow_grouping_value: grouping == true,
            number_flow_precision_value: Integer(precision),
            number_flow_locale_value: locale
          },
          normalize_data_hash(data),
          normalize_data_hash(extra_data)
        )
      }.merge(html_options.compact)

      content_tag(:span, **root_options) do
        safe_join(formatted_value.chars.map { |char| build_character_fragment(char) })
      end
    rescue ArgumentError, TypeError
      raise ArgumentError, 'number_flow_tag expects a numeric value'
    end

    private

    def coerce_number(value)
      case value
      when Integer, Float
        value
      when String
        Float(value)
      else
        value.respond_to?(:to_f) ? Float(value.to_f) : (raise ArgumentError)
      end
    end

    def build_character_fragment(char)
      if char.match?(/\d/)
        build_digit_fragment(char.to_i)
      else
        content_tag(:span, char, class: 'nf__separator', 'aria-hidden': 'true')
      end
    end

    def build_digit_fragment(digit)
      cells = safe_join(
        (0..9).map do |value|
          content_tag(:span, value.to_s, class: 'nf__cell', 'aria-hidden': 'true')
        end
      )

      content_tag(:span, class: 'nf__digit', data: { digit: digit }) do
        content_tag(
          :span,
          cells,
          class: 'nf__track',
          data: { to_digit: digit },
          style: "--nf-current-digit: #{digit}; --nf-from-digit: #{digit}; --nf-to-digit: #{digit};"
        )
      end
    end

    def format_number(value, precision:, grouping:, locale:)
      sign = value.negative? ? '-' : ''
      abs_value = value.abs
      decimal_sep = locale_decimal_separator(locale)
      group_sep = locale_group_separator(locale)

      if precision.positive?
        integer_part = Integer(abs_value.floor)
        fraction = format('%.0f', (abs_value - integer_part) * (10**precision)).rjust(precision, '0')
        number_str = "#{group_digits(integer_part, grouping, group_sep)}#{decimal_sep}#{fraction}"
      else
        number_str = group_digits(Integer(abs_value), grouping, group_sep)
      end

      "#{sign}#{number_str}"
    end

    def group_digits(integer, grouping, separator)
      digits = integer.to_s
      return digits unless grouping

      digits.reverse.scan(/.{1,3}/).join(separator).reverse
    end

    def locale_decimal_separator(locale)
      return ',' if locale && !locale.start_with?('en')

      '.'
    end

    def locale_group_separator(locale)
      return '.' if locale && !locale.start_with?('en')

      ','
    end

    def merged_data_attributes(*hashes)
      hashes.each_with_object({}) do |hash, merged|
        hash.each { |key, value| merged[key.to_sym] = value unless value.nil? }
      end
    end

    def normalize_data_hash(data)
      return {} unless data.respond_to?(:each)

      data.transform_keys do |key|
        key.to_s.tr('-', '_').to_sym
      end
    end
  end
end
