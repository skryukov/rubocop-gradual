# frozen_string_literal: true

module RuboCop
  module Gradual
    class Process
      # Printer class prints the results of the RuboCop Gradual process.
      class Printer
        def initialize(diff)
          @diff = diff
        end

        def print_results
          puts diff.statistics if Configuration.debug?

          send :"print_#{diff.state}"
        end

        def print_ci_warning(diff)
          puts <<~MSG
            \n#{bold("Unexpected Changes!")}

            RuboCop Gradual lock file is outdated, to fix this message:
            - Run `rubocop-gradual` locally and commit the results, or
            - EVEN BETTER: before doing the above, try to fix the remaining issues in those files!

            #{bold("`#{Configuration.path}` diff:")}

            #{diff.to_s(ARGV.include?("--no-color") ? :text : :color)}
          MSG
        end

        private

        attr_reader :diff

        def print_complete
          puts bold("RuboCop Gradual is complete!")
          puts "Removing `#{Configuration.path}` lock file..." if diff.statistics[:fixed].positive?
        end

        def print_updated
          puts bold("RuboCop Gradual got its results updated.")
        end

        def print_no_changes
          puts bold("RuboCop Gradual got no changes.")
        end

        def print_new
          issues_left = diff.statistics[:left]
          puts bold("RuboCop Gradual got results for the first time. #{issues_left} issue(s) found.")
          puts "Don't forget to commit `#{Configuration.path}` log file."
        end

        def print_better
          issues_left = diff.statistics[:left]
          issues_fixed = diff.statistics[:fixed]
          puts bold("RuboCop Gradual got #{issues_fixed} issue(s) fixed, #{issues_left} left. Keep going!")
        end

        def print_worse
          puts bold("Uh oh, RuboCop Gradual got worse:")
          print_new_issues
          puts bold("Force updating lock file...") if Configuration.mode == :force_update
        end

        def print_new_issues
          diff.files.each do |path, issues|
            next if issues[:new].empty?

            puts "-> #{path} (#{issues[:new].size} new issues)"
            issues[:new].each do |issue|
              puts "    (line #{issue.line}) \"#{issue.message}\""
            end
          end
        end

        def bold(str)
          rainbow.wrap(str).bright
        end

        def rainbow
          @rainbow ||= Rainbow.new.tap do |r|
            r.enabled = false if ARGV.include?("--no-color")
          end
        end
      end
    end
  end
end
