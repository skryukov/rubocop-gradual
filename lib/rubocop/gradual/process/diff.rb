# frozen_string_literal: true

module RuboCop
  module Gradual
    class Process
      # Diff class represents the difference between two RuboCop Gradual results.
      class Diff
        attr_reader :files

        def initialize
          @files = {}
        end

        def state
          return :new if new?
          return :complete if statistics[:left].zero?
          return :worse if statistics[:new].positive?
          return :better if statistics[:fixed].positive?
          return :updated if statistics[:moved].positive?

          :no_changes
        end

        def statistics
          @statistics ||=
            begin
              fixed = count_issues(:fixed)
              moved = count_issues(:moved)
              new = count_issues(:new)
              unchanged = count_issues(:unchanged)
              left = moved + new + unchanged
              { fixed: fixed, moved: moved, new: new, unchanged: unchanged, left: left }
            end
        end

        def add_new(files)
          files.each do |file|
            add_issues(file.path, new: file.issues)
          end
          self
        end

        def add_fixed(files)
          files.each do |file|
            add_issues(file.path, fixed: file.issues)
          end
          self
        end

        def add_issues(path, fixed: [], moved: [], new: [], unchanged: [])
          @files[path] = {
            fixed: fixed,
            moved: moved,
            new: new,
            unchanged: unchanged
          }
          log_file_issues(path) if Configuration.debug?
          self
        end

        private

        def new?
          statistics[:new].positive? && statistics[:new] == statistics[:left]
        end

        def count_issues(key)
          @files.values.sum { |v| v[key].size }
        end

        def log_file_issues(file_path)
          puts "#{file_path}:"
          @files[file_path].each do |key, issues|
            puts "  #{key}: #{issues.size}"
            next if issues.empty?

            puts "    #{issues.join("\n    ")}"
          end
        end
      end
    end
  end
end
