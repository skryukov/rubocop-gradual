# frozen_string_literal: true

require "benchmark"
require "pathname"

require_relative "process"

module RuboCop
  module Gradual
    # Formatter is a RuboCop formatter class that collects RuboCop results and
    # calls the Gradual::Process class at the end to process them.
    class Formatter < RuboCop::Formatter::BaseFormatter
      include PathUtil

      attr_reader :output_hash

      def initialize(_output, options = {})
        super
        Gradual.debug = options[:debug]
        puts "Gradual mode: #{Gradual.mode}" if Gradual.debug
        @output_hash = { files: [] }
      end

      def file_finished(file, offenses)
        print "."
        return if offenses.empty?

        output_hash[:files] << {
          path: smart_path(file),
          issues: offenses.reject(&:corrected?).map { |o| issue_offense(o) }
        }
      end

      def finished(_inspected_files)
        puts "\n#{stats_message}"
        puts "Processing results..."

        time = Benchmark.realtime { Process.new(output_hash).call }

        puts "Finished Gradual processing in #{time} seconds" if options[:debug] || options[:display_time]
      end

      private

      def issue_offense(offense)
        {
          line: offense.line,
          column: offense.real_column,
          length: offense.location.length,
          message: offense.message
        }
      end

      def stats_message
        issues_count = output_hash[:files].sum { |f| f[:issues].size }
        "Found #{output_hash[:files].size} files with #{issues_count} issue(s)."
      end
    end
  end
end
