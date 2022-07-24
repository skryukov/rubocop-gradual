# frozen_string_literal: true

require "pathname"

module RuboCop
  module Gradual
    module Formatters
      # Formatter is a RuboCop formatter class that collects RuboCop results and
      # calls the Gradual::Process class at the end to process them.
      class Autocorrect < RuboCop::Formatter::BaseFormatter
        include PathUtil

        def initialize(_output, options = {})
          super
          @corrected_files = 0
        end

        def started(target_files)
          puts "Inspecting #{target_files.size} file(s) for autocorrection..."
        end

        def file_finished(_file, offenses)
          print "."
          return if offenses.empty?

          @corrected_files += 1 if offenses.any?(&:corrected?)
        end

        def finished(_inspected_files)
          puts "\nFixed #{@corrected_files} file(s).\n"
        end
      end
    end
  end
end
