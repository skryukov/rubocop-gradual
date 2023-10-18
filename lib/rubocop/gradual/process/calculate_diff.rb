# frozen_string_literal: true

require_relative "diff"
require_relative "matcher"

module RuboCop
  module Gradual
    class Process
      # CalculateDiff calculates the difference between two RuboCop Gradual results.
      module CalculateDiff
        class << self
          def call(new_result, old_result)
            return Diff.new.add_files(new_result.files, :new) if old_result.nil?

            diff_results(new_result, old_result)
          end

          private

          def diff_results(new_result, old_result)
            new_files, fixed_files, path_files_match, moved_files_match = split_files(new_result, old_result)

            diff = Diff.new.add_files(new_files, :new).add_files(fixed_files, :fixed)
            path_files_match.chain(moved_files_match).each do |result_file, old_file|
              diff_issues(diff, result_file, old_file)
            end

            diff
          end

          def split_files(new_result, old_result)
            path_files_match = Matcher.new(new_result.files, old_result.files, :path)
            new_or_moved_files = path_files_match.unmatched_keys
            fixed_or_moved_files = path_files_match.unmatched_values

            moved_files_match = Matcher.new(new_or_moved_files, fixed_or_moved_files, :file_hash)
            new_files = moved_files_match.unmatched_keys
            fixed_files = moved_files_match.unmatched_values

            [new_files, fixed_files, path_files_match, moved_files_match]
          end

          def diff_issues(diff, result_file, old_file)
            fixed_or_moved = old_file.changed_issues(result_file)
            new_or_moved = result_file.changed_issues(old_file)
            moved, fixed = split_issues(fixed_or_moved, new_or_moved)
            new = new_or_moved - moved
            unchanged = result_file.issues - new - moved

            if result_file.file_hash != old_file.file_hash && fixed.empty? && new.empty? && moved.empty?
              moved = unchanged
              unchanged = []
            end

            diff.add_issues(result_file.path, fixed: fixed, moved: moved, new: new, unchanged: unchanged)
          end

          def split_issues(fixed_or_moved_issues, new_or_moved_issues)
            possibilities = new_or_moved_issues.dup
            fixed_issues = []
            moved_issues = []
            fixed_or_moved_issues.each do |fixed_or_moved_issue|
              best = best_possibility(fixed_or_moved_issue, possibilities)
              next fixed_issues << fixed_or_moved_issue if best.nil?

              moved_issues << possibilities.delete(best)
            end
            [moved_issues, fixed_issues]
          end

          def best_possibility(issue, possible_issues)
            possibilities = possible_issues.select do |possible_issue|
              possible_issue.code_hash == issue.code_hash
            end
            possibilities.min_by { |possibility| issue.distance(possibility) }
          end
        end
      end
    end
  end
end
