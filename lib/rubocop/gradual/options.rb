# frozen_string_literal: true

require "rainbow"
require "shellwords"

module RuboCop
  module Gradual
    # Options class defines RuboCop Gradual cli options.
    # It also extracts command line RuboCop Gradual arguments
    # before passing leftover arguments to RuboCop::CLI.
    class Options
      def parse(args)
        parser = define_options
        @gradual_args, @rubocop_args = filter_args(parser, args_from_file + args)
        parser.parse(@gradual_args)
        @rubocop_args
      end

      private

      def define_options
        OptionParser.new do |opts|
          opts.banner = rainbow.wrap("\nGradual options:").bright

          define_gradual_options(opts)

          define_proxy_options(opts)
        end
      end

      def define_gradual_options(opts)
        opts.on("-u", "--update", "Force update Gradual lock file.") { Gradual.mode = :update }

        opts.on("--ci", "Run Gradual in the CI mode.") { Gradual.mode = :ci }

        opts.on("--gradual-file FILE", "Specify Gradual lock file.") { |path| Gradual.path = path }

        opts.on("--no-gradual", "Disable Gradual.") { Gradual.mode = :disabled }
      end

      def define_proxy_options(opts)
        proxy_option(opts, "-v", "--version", "Display version.") do
          print "rubocop-gradual: #{VERSION}\nrubocop: "
        end

        proxy_option(opts, "-V", "--verbose-version", "Display verbose version.") do
          print "rubocop-gradual: #{VERSION}\nrubocop:"
        end

        proxy_option(opts, "-h", "--help", "Display help message.") do
          at_exit { puts opts }
        end
      end

      def proxy_option(opts, *attrs)
        opts.on(*attrs) do
          @rubocop_args << attrs[0]
          yield
        end
      end

      def filter_args(parser, original_args, self_args = [])
        extract_all_args(parser).each do |arg|
          loop do
            break unless (i = original_args.index { |a| a.start_with?(arg) })

            loop do
              self_args << original_args.delete_at(i)
              break if original_args.size <= i || original_args[i].start_with?("-")
            end
          end
        end
        [self_args, original_args]
      end

      def extract_all_args(parser)
        parser.top.list.reduce([]) do |res, option|
          res + option.long + option.short
        end
      end

      def args_from_file
        if File.exist?(".rubocop-gradual") && !File.directory?(".rubocop-gradual")
          File.read(".rubocop-gradual").shellsplit
        else
          []
        end
      end

      def rainbow
        @rainbow ||= Rainbow.new.tap do |r|
          r.enabled = false if ARGV.include?("--no-color")
        end
      end
    end
  end
end
