# frozen_string_literal: true

module RuboCop
  module Gradual
    # Configuration class stores Gradual and Rubocop options.
    module Configuration
      class << self
        attr_reader :options, :rubocop_options, :rubocop_results

        def apply(options = {}, rubocop_options = {})
          @options = options
          @rubocop_options = rubocop_options
          @rubocop_results = []
        end

        def command
          options.fetch(:command, :base)
        end

        def mode
          options.fetch(:mode, :update)
        end

        def path
          options.fetch(:path, ".rubocop_gradual.lock")
        end

        def debug?
          rubocop_options[:debug]
        end

        def display_time?
          rubocop_options[:debug] || rubocop_options[:display_time]
        end

        def rubocop_config_store
          RuboCop::ConfigStore.new.tap do |config_store|
            config_store.options_config = rubocop_options[:config] if rubocop_options[:config]
          end
        end
      end
    end
  end
end
