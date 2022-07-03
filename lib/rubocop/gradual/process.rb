# frozen_string_literal: true

require_relative "results"
require_relative "lock_file"
require_relative "process/calculate_diff"
require_relative "process/printer"

module RuboCop
  module Gradual
    # Process is a class that handles the processing of RuboCop results.
    class Process
      attr_reader :new_results, :lock_file

      def initialize(rubocop_result)
        @lock_file = LockFile.new(Gradual.path)
        @new_results = Results.new(**rubocop_result)
      end

      def call
        diff = CalculateDiff.call(new_results, lock_file.read_results)
        printer = Printer.new(diff)
        if print_ci_warning?(diff)
          printer.print_ci_warning(lock_file.diff(new_results))
        else
          printer.print_results
        end

        Gradual.exit_code = error_code(diff)

        sync_lock_file(diff)
      end

      private

      def print_ci_warning?(diff)
        Gradual.mode == :ci && diff.state != :no_changes && diff.state != :worse
      end

      def sync_lock_file(diff)
        return unless Gradual.exit_code.zero?
        return lock_file.delete if diff.state == :complete

        lock_file.write_results(new_results)
      end

      def error_code(diff)
        return 1 if print_ci_warning?(diff)
        return 1 if diff.state == :worse && Gradual.mode != :update

        0
      end
    end
  end
end
