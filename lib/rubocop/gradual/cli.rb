# frozen_string_literal: true

require_relative "options"
require_relative "formatter"

module RuboCop
  module Gradual
    # CLI is a wrapper around RuboCop::CLI.
    class CLI < RuboCop::CLI
      def run(args = ARGV)
        Gradual.mode = :base
        rubocop_args = Options.new.parse(args)
        super(rubocop_args)
      end

      private

      def apply_default_formatter
        return super if Gradual.mode == :disabled
        raise OptionArgumentError, "-f, --format cannot be used in gradual mode." if @options[:formatters]

        @options[:formatters] = [[Formatter, nil]]
      end

      def execute_runners
        raise OptionArgumentError, "--auto-gen-config cannot be used in gradual mode." if @options[:auto_gen_config]

        result = super
        Gradual.mode == :disabled ? result : Gradual.exit_code
      end
    end
  end
end
