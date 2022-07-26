# frozen_string_literal: true

require "rake"
require "rake/tasklib"

module RuboCop
  module Gradual
    # Rake tasks for RuboCop::Gradual.
    #
    # @example
    #   require "rubocop/gradual/rake_task"
    #   RuboCop::Gradual::RakeTask.new
    #
    class RakeTask < ::Rake::TaskLib
      attr_accessor :name, :verbose, :options

      def initialize(name = :rubocop_gradual, *args, &task_block)
        super()
        @name = name
        @verbose = true
        @options = []
        define(args, &task_block)
      end

      private

      def define(args, &task_block)
        desc "Run RuboCop Gradual" unless ::Rake.application.last_description
        define_task(name, nil, args, &task_block)
        setup_subtasks(args, &task_block)
      end

      def setup_subtasks(args, &task_block)
        namespace(name) do
          desc "Run RuboCop Gradual with autocorrect (only when it's safe)."
          define_task(:autocorrect, "--autocorrect", args, &task_block)

          desc "Run RuboCop Gradual with autocorrect (safe and unsafe)."
          define_task(:autocorrect_all, "--autocorrect-all", args, &task_block)

          desc "Run RuboCop Gradual to check the lock file."
          define_task(:check, "--check", args, &task_block)

          desc "Run RuboCop Gradual to force update the lock file."
          define_task(:force_update, "--force-update", args, &task_block)
        end
      end

      def define_task(name, option, args, &task_block)
        task(name, *args) do |_, task_args|
          RakeFileUtils.verbose(verbose) do
            yield(*[self, task_args].slice(0, task_block.arity)) if task_block
            run_cli(verbose, option)
          end
        end
      end

      def run_cli(verbose, option)
        require "rubocop-gradual"

        cli = CLI.new
        puts "Running RuboCop Gradual..." if verbose
        result = cli.run(full_options(option))
        abort("RuboCop Gradual failed!") if result.nonzero?
      end

      def full_options(option)
        option ? options.flatten.unshift(option) : options.flatten
      end
    end
  end
end
