# frozen_string_literal: true

require_relative 'number_flow/version'
require_relative 'number_flow/helper'
require_relative 'number_flow/engine'

module NumberFlow
  class Error < StandardError; end
end

# Load optional ViewComponent wrapper if the gem is present.
begin
  require 'view_component'
  require_relative '../app/components/number_flow/component'
rescue LoadError
  # ViewComponent is not installed — Component stays undefined.
end

# Load Rails generators when Rails is available.
begin
  require 'rails'
  require_relative '../generators/number_flow/install/install_generator'
rescue LoadError
  # Rails is not available — generators are not loaded.
end
