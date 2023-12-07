# frozen_string_literal: true

require_relative "configuration"
require_relative "options"

module RuboCop
  module Gradual
    # CLI is a wrapper around RuboCop::CLI.
    class CLI
      def run(argv = ARGV)
        Configuration.apply(*Options.new.parse(argv))
        puts "Gradual mode: #{Configuration.mode}" if Configuration.debug?
        cmd = load_command(Configuration.command)
        return list_target_files(cmd) if Configuration.rubocop_options[:list_target_files]

        cmd.call.to_i
      end

      private

      def list_target_files(cmd)
        cmd.lint_paths.each { |path| puts PathUtil.relative_path(path) }
        1
      end

      def load_command(command)
        require_relative "commands/#{command}"
        ::RuboCop::Gradual::Commands.const_get(command.to_s.capitalize).new
      end
    end
  end
end
