# frozen_string_literal: true

require_relative "base"
require_relative "../formatters/autocorrect"

module RuboCop
  module Gradual
    module Commands
      # Autocorrect command runs RuboCop autocorrect before running the base command.
      class Autocorrect
        def call
          runner = RuboCop::CLI::Command::ExecuteRunner.new(
            RuboCop::CLI::Environment.new(
              Configuration.rubocop_options.merge(formatters: [[Formatters::Autocorrect, nil]]),
              Configuration.rubocop_config_store,
              changed_or_untracked_files.map(&:path)
            )
          )
          runner.run
          Base.new.call
        end

        private

        def changed_or_untracked_files
          tracked_files = LockFile.new(Configuration.path).read_results&.files || []

          target_files.reject do |file|
            tracked_files.any? { |r| r.path == file.path && r.file_hash == file.file_hash }
          end
        end

        def target_files
          Parallel.map(rubocop_target_file_paths) do |path|
            Results::File.new(path: RuboCop::PathUtil.smart_path(path), issues: [])
          end
        end

        def rubocop_target_file_paths
          target_finder = RuboCop::TargetFinder.new(Configuration.rubocop_config_store, Configuration.rubocop_options)
          mode = if Configuration.rubocop_options[:only_recognized_file_types]
                   :only_recognized_file_types
                 else
                   :all_file_types
                 end
          target_finder.find([], mode)
        end
      end
    end
  end
end
