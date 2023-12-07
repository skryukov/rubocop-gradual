# frozen_string_literal: true

require "benchmark"

require_relative "../formatters/base"
require_relative "../process"

module RuboCop
  module Gradual
    module Commands
      # Base command runs RuboCop, and processes the results with Gradual.
      class Base
        def call
          exit_code = 0
          run_rubocop
          write_stats_message
          time = Benchmark.realtime { exit_code = Process.new(Configuration.rubocop_results).call }
          puts "Finished Gradual processing in #{time} seconds" if Configuration.display_time?

          exit_code
        rescue RuboCop::Error => e
          warn "\nRuboCop Error: #{e.message}"
          1
        end

        def lint_paths
          Configuration.target_file_paths
        end

        private

        def run_rubocop
          rubocop_runner = RuboCop::CLI::Command::ExecuteRunner.new(
            RuboCop::CLI::Environment.new(
              rubocop_options,
              Configuration.rubocop_config_store,
              lint_paths
            )
          )
          rubocop_runner.run
        end

        def rubocop_options
          Configuration.rubocop_options
                       .slice(:config, :debug, :display_time)
                       .merge(formatters: [[Formatters::Base, nil]])
        end

        def write_stats_message
          issues_count = Configuration.rubocop_results.sum { |f| f[:issues].size }
          puts "\nFound #{Configuration.rubocop_results.size} files with #{issues_count} issue(s)."
          puts "Processing results..."
        end
      end
    end
  end
end
