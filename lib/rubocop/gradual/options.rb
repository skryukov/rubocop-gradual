# frozen_string_literal: true

require "shellwords"

require_relative "git"

module RuboCop
  module Gradual
    # Options class defines RuboCop Gradual cli options.
    class Options
      AUTOCORRECT_KEY =
        if Gem::Version.new(RuboCop::Version::STRING) >= Gem::Version.new("1.30")
          :autocorrect
        else
          :auto_correct
        end

      def initialize
        @options = {}
      end

      def parse(args)
        parser = define_options
        gradual_args, rubocop_args = filter_args(parser, args_from_file + args)
        @rubocop_options, @lint_paths = RuboCop::Options.new.parse(rubocop_args)
        parser.parse(gradual_args)

        [@options, @rubocop_options, @lint_paths]
      end

      private

      def define_options
        OptionParser.new do |opts|
          define_mode_options(opts)
          define_gradual_options(opts)
          define_lint_paths_options(opts)

          define_info_options(opts)
        end
      end

      def define_mode_options(opts)
        opts.on("-U", "--force-update", "Force update Gradual lock file.") { @options[:mode] = :force_update }
        opts.on("-u", "--update", "Same as --force-update (deprecated).") do
          warn "-u, --update is deprecated. Use -U, --force-update instead."
          @options[:mode] = :force_update
        end

        opts.on("--check", "Check Gradual lock file is up-to-date.") { @options[:mode] = :check }
        opts.on("--ci", "Same as --check (deprecated).") do
          warn "--ci is deprecated. Use --check instead."
          @options[:mode] = :check
        end
      end

      def define_gradual_options(opts)
        opts.on("-a", "--autocorrect", "Autocorrect offenses (only when it's safe).") do
          @rubocop_options[AUTOCORRECT_KEY] = true
          @rubocop_options[:"safe_#{AUTOCORRECT_KEY}"] = true
          @options[:command] = :autocorrect
        end
        opts.on("-A", "--autocorrect-all", "Autocorrect offenses (safe and unsafe).") do
          @rubocop_options[AUTOCORRECT_KEY] = true
          @options[:command] = :autocorrect
        end

        opts.on("--gradual-file FILE", "Specify Gradual lock file.") { |path| @options[:path] = path }
      end

      def define_lint_paths_options(opts)
        opts.on("--unstaged", "Lint unstaged files.") do
          @lint_paths = git_lint_paths(:unstaged)
        end
        opts.on("--staged", "Lint staged files.") do
          @lint_paths = git_lint_paths(:staged)
        end
        opts.on("--commit COMMIT", "Lint files changed since the commit.") do |commit|
          @lint_paths = git_lint_paths(commit)
        end
      end

      def define_info_options(opts)
        opts.on("-v", "--version", "Display version.") do
          puts "rubocop-gradual: #{VERSION}, rubocop: #{RuboCop::Version.version}"
          exit
        end

        opts.on("-h", "--help", "Prints this help.") do
          puts opts
          exit
        end
      end

      def git_lint_paths(commit)
        @rubocop_options[:only_recognized_file_types] = true
        RuboCop::Gradual::Git.paths_by(commit)
      end

      def filter_args(parser, original_args, self_args = [])
        extract_all_args(parser).each do |option|
          loop do
            break unless (i = original_args.index { |a| a.start_with?(option[:name]) })

            self_args << original_args.delete_at(i)
            next if option[:no_args] || original_args.size <= i || original_args[i].start_with?("-")

            self_args << original_args.delete_at(i)
          end
        end
        [self_args, original_args]
      end

      def extract_all_args(parser)
        parser.top.list.reduce([]) do |res, option|
          no_args = option.is_a?(OptionParser::Switch::NoArgument)
          options = (option.long + option.short).map { |o| { name: o, no_args: no_args } }
          res + options
        end
      end

      def args_from_file
        if File.exist?(".rubocop-gradual") && !File.directory?(".rubocop-gradual")
          File.read(".rubocop-gradual").shellsplit
        else
          []
        end
      end
    end
  end
end
