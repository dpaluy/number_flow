# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'minitest/test_task'

Minitest::TestTask.create

rubocop_available = false

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
  rubocop_available = true
rescue LoadError
  # RuboCop not available in this environment.
end

task default: (rubocop_available ? %i[test rubocop] : :test)
