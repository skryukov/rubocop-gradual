# frozen_string_literal: true

module RuboCop
  module Gradual
    # Configuration class stores Gradual and Rubocop options.
    module Configuration
      class << self
        attr_reader :options, :rubocop_options, :rubocop_results, :lint_paths, :target_file_paths

        def apply(options = {}, rubocop_options = {}, lint_paths = [])
          @options = options
          @rubocop_options = rubocop_options
          @lint_paths = lint_paths
          @target_file_paths = rubocop_target_file_paths
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

        private

        def rubocop_target_file_paths
          target_finder = RuboCop::TargetFinder.new(rubocop_config_store, rubocop_options)
          mode = if rubocop_options[:only_recognized_file_types]
                   :only_recognized_file_types
                 else
                   :all_file_types
                 end
          target_finder
            .find(lint_paths, mode)
            .map { |path| RuboCop::PathUtil.smart_path(path) }
        end
      end
    end
  end
end
