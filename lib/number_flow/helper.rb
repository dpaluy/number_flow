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
      aria_label: nil,
      data: {},
      **html_options
    )
      normalized_value = Integer(value)
      formatted_value = format_integer(normalized_value, grouping: grouping)
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
            number_flow_grouping_value: grouping == true
          },
          normalize_data_hash(data),
          normalize_data_hash(extra_data)
        )
      }.merge(html_options.compact)

      content_tag(:span, **root_options) do
        safe_join(formatted_value.chars.map { |char| build_character_fragment(char) })
      end
    rescue ArgumentError, TypeError
      raise ArgumentError, 'number_flow_tag expects an integer-compatible value'
    end

    private

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

    def format_integer(value, grouping:)
      sign = value.negative? ? '-' : ''
      digits = value.abs.to_s
      grouped = grouping ? digits.reverse.scan(/.{1,3}/).join(',').reverse : digits
      "#{sign}#{grouped}"
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
