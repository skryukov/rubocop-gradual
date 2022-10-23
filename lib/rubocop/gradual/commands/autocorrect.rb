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
              lint_paths
            )
          )
          runner.run
          Base.new.call
        end

        private

        def lint_paths
          return Configuration.target_file_paths if Configuration.lint_paths.any?

          changed_or_untracked_files.map(&:path)
        end

        def changed_or_untracked_files
          tracked_files = LockFile.new(Configuration.path).read_results&.files || []

          target_files.reject do |file|
            tracked_files.any? { |r| r.path == file.path && r.file_hash == file.file_hash }
          end
        end

        def target_files
          Parallel.map(Configuration.target_file_paths) do |path|
            Results::File.new(path: path, issues: [])
          end
        end
      end
    end
  end
end
