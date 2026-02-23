# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'number_flow'

require 'minitest/autorun'
require 'action_view'

module NumberFlowTestSupport
  def build_view
    ActionView::Base.empty.tap do |view|
      view.extend(NumberFlow::Helper)
    end
  end
end
