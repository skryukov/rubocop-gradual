# frozen_string_literal: true

require "pathname"

module RuboCop
  module Gradual
    module Formatters
      # Base is a RuboCop formatter class that collects RuboCop results and
      # writes them to Configuration.rubocop_results.
      class Base < RuboCop::Formatter::BaseFormatter
        include PathUtil

        def file_finished(file, offenses)
          print "."
          return if offenses.empty?

          Configuration.rubocop_results << {
            path: smart_path(file),
            issues: offenses.reject(&:corrected?).map { |o| issue_offense(o) }
          }
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
      end
    end
  end
end
