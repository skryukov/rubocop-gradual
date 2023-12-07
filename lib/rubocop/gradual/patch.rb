# frozen_string_literal: true

require "rubocop-gradual"

module RuboCop
  module Gradual
    # Patching RuboCop::CLI to enable require mode.
    module Patch
      def run_command(name)
        return super if name != :execute_runner || (ARGV & %w[--stdin -s]).any?

        RuboCop::Gradual::CLI.new.run(patched_argv)
      end

      private

      def patched_argv
        return ARGV if ARGV[0] != "gradual"

        case ARGV[1]
        when "force_update"
          ARGV[2..] + ["--force-update"]
        when "check"
          ARGV[2..] + ["--check"]
        else
          raise ArgumentError, "Unknown gradual command #{ARGV[1]}"
        end
      end
    end
  end
end

RuboCop::CLI.prepend(RuboCop::Gradual::Patch) if ENV["NO_GRADUAL"] != "1"
