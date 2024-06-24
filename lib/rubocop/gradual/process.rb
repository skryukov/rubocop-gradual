# frozen_string_literal: true

require_relative "results"
require_relative "lock_file"
require_relative "process/calculate_diff"
require_relative "process/printer"

module RuboCop
  module Gradual
    # Process is a class that handles the processing of RuboCop results.
    class Process
      attr_reader :lock_file, :old_results, :new_results

      def initialize(rubocop_result)
        @lock_file = LockFile.new(Configuration.path)
        @old_results = lock_file.read_results
        @new_results = Results.new(files: rubocop_result)
        add_skipped_files_to_new_results!
      end

      def call
        diff = CalculateDiff.call(new_results, old_results)
        printer = Printer.new(diff)

        printer.print_results
        if fail_with_outdated_lock?(diff)
          printer.print_ci_warning(lock_file.diff(new_results), statistics: diff.statistics)
        end

        exit_code = error_code(diff)
        sync_lock_file(diff) if exit_code.zero?
        exit_code
      end

      private

      def fail_with_outdated_lock?(diff)
        Configuration.mode == :check && diff.state != :no_changes
      end

      def sync_lock_file(diff)
        return lock_file.delete if diff.state == :complete

        lock_file.write_results(new_results)
      end

      def error_code(diff)
        return 1 if fail_with_outdated_lock?(diff)
        return 1 if diff.state == :worse && Configuration.mode != :force_update

        0
      end

      def add_skipped_files_to_new_results!
        return if Configuration.lint_paths.none? || old_results.nil?

        skipped_files = old_results.files.reject { |file| Configuration.target_file_paths.include?(file.path) }
        new_results.files.concat(skipped_files).sort!
      end
    end
  end
end
