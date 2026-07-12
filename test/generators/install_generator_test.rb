# frozen_string_literal: true

require_relative '../test_helper'
require 'rails'
require 'action_controller/railtie'
require 'rails/generators'
require 'rails/generators/test_case'
require 'tmpdir'
require 'fileutils'

# Do NOT directly require the generator file here.
# The generator must be loaded via require 'number_flow' (already done in
# test_helper), which exercises the real load path in lib/number_flow.rb.
# This test catches dead require_relative paths.

module NumberFlow
  class InstallGeneratorTest < Rails::Generators::TestCase
    tests NumberFlow::Generators::InstallGenerator
    destination File.join(Dir.mktmpdir, 'vite_sandbox')
    setup :prepare_destination

    def setup
      super
      FileUtils.mkdir_p(File.join(destination_root, 'app/frontend/controllers'))
      FileUtils.mkdir_p(File.join(destination_root, 'app/frontend/stylesheets'))
      FileUtils.mkdir_p(File.join(destination_root, 'app/frontend/entrypoints'))
      FileUtils.mkdir_p(File.join(destination_root, 'app/assets/javascripts/number_flow'))
      FileUtils.mkdir_p(File.join(destination_root, 'app/assets/stylesheets'))
    end

    def source_paths
      [File.expand_path('../../..', __dir__)]
    end

    def test_vite_install_copies_controller_and_css
      run_generator %w[--vite]

      assert_file File.join(destination_root, 'app/frontend/controllers/number_flow_controller.js') do |content|
        assert_includes content, 'import { Controller } from "@hotwired/stimulus"'
        assert_includes content, 'precision'
        assert_includes content, 'Intl.NumberFormat'
      end

      assert_file File.join(destination_root, 'app/frontend/stylesheets/number_flow.css') do |content|
        assert_includes content, '.nf'
      end
    end

    def test_vite_install_appends_to_entrypoint
      entrypoint = File.join(destination_root, 'app/frontend/entrypoints/application.js')
      File.write(entrypoint, %(import application from "../application.js"\napplication = Application.start()\n))

      run_generator %w[--vite]

      content = File.read(entrypoint)
      assert_includes content, 'import NumberFlowController from "../controllers/number_flow_controller"'
      assert_includes content, 'application.register("number-flow", NumberFlowController)'
    end

    def test_vite_install_is_idempotent
      entrypoint = File.join(destination_root, 'app/frontend/entrypoints/application.js')
      File.write(entrypoint, %(import application from "../application.js"\napplication = Application.start()\n))

      run_generator %w[--vite]
      run_generator %w[--vite]

      content = File.read(entrypoint)
      import_count = content.scan('import NumberFlowController').length
      register_count = content.scan('application.register("number-flow"').length

      assert_equal 1, import_count, 'Generator should not duplicate import line on re-run'
      assert_equal 1, register_count, 'Generator should not duplicate register line on re-run'
    end

    def test_vite_install_does_not_require_entrypoint
      entrypoint = File.join(destination_root, 'app/frontend/entrypoints/application.js')
      FileUtils.rm_f(entrypoint)

      run_generator %w[--vite]

      assert_file 'app/frontend/controllers/number_flow_controller.js'
      refute File.exist?(entrypoint), 'Should not create entrypoint if missing'
    end

    def test_standard_install_does_not_copy_files
      run_generator []

      refute File.exist?(File.join(destination_root, 'app/frontend/controllers/number_flow_controller.js'))
      refute File.exist?(File.join(destination_root, 'app/frontend/stylesheets/number_flow.css'))
    end

    # Regression test: lib/number_flow.rb must load the generator via the
    # correct require_relative path so it is available after require 'number_flow'.
    # This catches dead path bugs (e.g. '../generators' instead of 'generators').
    def test_generator_loaded_via_require_number_flow
      assert defined?(NumberFlow::Generators::InstallGenerator),
             'NumberFlow::Generators::InstallGenerator must be defined after require \'number_flow\''
    end
  end
end
