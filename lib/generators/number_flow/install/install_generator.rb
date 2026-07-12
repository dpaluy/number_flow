# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/base'

module NumberFlow
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Install NumberFlow for your asset pipeline (Sprockets, importmap, or Vite Rails).'

      class_option :vite, type: :boolean, default: false,
                          desc: 'Copy controller and stylesheet into app/frontend for Vite Rails'

      source_root File.expand_path('../../../..', __dir__)

      CONTROLLER_SOURCE = 'app/assets/javascripts/number_flow/controller.js'
      CSS_SOURCE = 'app/assets/stylesheets/number_flow.css'
      VITE_CONTROLLER_TARGET = 'app/frontend/controllers/number_flow_controller.js'
      VITE_CSS_TARGET = 'app/frontend/stylesheets/number_flow.css'
      VITE_ENTRYPOINT = 'app/frontend/entrypoints/application.js'

      def install
        if options[:vite]
          install_vite
        else
          install_standard
        end
      end

      private

      def install_vite
        say_status('info', 'Installing NumberFlow for Vite Rails', :blue)

        copy_file(CONTROLLER_SOURCE, VITE_CONTROLLER_TARGET)
        copy_file(CSS_SOURCE, VITE_CSS_TARGET)
        register_stimulus_controller
      end

      def install_standard
        say_status('info', 'NumberFlow assets are served from the gem (Sprockets/importmap).', :blue)
        say('')
        say('1. Load the stylesheet in your layout:')
        say('   <%= stylesheet_link_tag "number_flow", "data-turbo-track": "reload" %>')
        say('')
        say('2. Pin the controller (config/importmap.rb):')
        say('   pin "number_flow/controller", to: "number_flow/controller.js"')
        say('')
        say('3. Register in app/javascript/controllers/index.js:')
        say('   import NumberFlowController from "number_flow/controller"')
        say('   application.register("number-flow", NumberFlowController)')
      end

      def register_stimulus_controller
        return unless File.exist?(File.expand_path(VITE_ENTRYPOINT, destination_root))

        entrypoint_path = File.expand_path(VITE_ENTRYPOINT, destination_root)
        content = File.read(entrypoint_path)

        import_line = 'import NumberFlowController from "../controllers/number_flow_controller"'
        register_line = 'application.register("number-flow", NumberFlowController)'

        return if content.include?(import_line)

        inject_into_file(VITE_ENTRYPOINT, "  #{import_line}\n", after: /import application from.*\n/)

        unless content.include?(register_line)
          inject_into_file(VITE_ENTRYPOINT, "  #{register_line}\n",
                           after: /application = Application\.start.*\n/)
        end

        say_status('create', "#{VITE_ENTRYPOINT} (updated)", :green)
      end
    end
  end
end
