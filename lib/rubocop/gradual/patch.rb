# frozen_string_literal: true

require "rubocop-gradual"

module RuboCop
  module Gradual
    # Patching RuboCop::CLI to enable require mode.
    module Patch
      def run_command(name)
        return super if name != :execute_runner || (ARGV & %w[--stdin -s]).any?

        Configuration.apply(*parse_options)
        puts "Gradual mode: #{Configuration.mode}" if Configuration.debug?
        load_command(Configuration.command).call.to_i
      end

      private

      def load_command(command)
        require_relative "commands/#{command}"
        ::RuboCop::Gradual::Commands.const_get(command.to_s.capitalize).new
      end

      def parse_options
        options, rubocop_options = Options.new.parse(ARGV)
        options[:mode] = :force_update if @env.paths[0..1] == %w[gradual force_update]
        options[:mode] = :check if @env.paths[0..1] == %w[gradual check]
        [options, rubocop_options]
      end
    end
  end
end
