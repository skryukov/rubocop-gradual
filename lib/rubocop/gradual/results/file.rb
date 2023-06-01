# frozen_string_literal: true

require_relative "issue"

module RuboCop
  module Gradual
    class Results
      # File is a representation of a file in a Gradual results.
      class File
        attr_reader :path, :issues, :file_hash, :state

        def initialize(path:, issues:, hash: nil)
          @path = path
          @file_hash = hash || djb2a(data)
          @issues = prepare_issues(issues).sort
          @data = nil
        end

        def <=>(other)
          path <=> other.path
        end

        def changed_issues(other_file)
          issues.reject do |result_issue|
            other_file.issues.find { |other_issue| result_issue == other_issue }
          end
        end

        private

        def prepare_issues(issues)
          issues.map { |issue| Issue.new(**issue.merge(hash: issue_hash(issue))) }
        end

        def issue_hash(issue)
          return issue[:hash] if issue[:hash]

          djb2a(fetch_code(issue[:line] - 1, issue[:column] - 1, issue[:length]))
        end

        def fetch_code(line, column, length)
          code = ""
          data.each_line.lazy.drop(line).each_with_index do |str, index|
            from = index.zero? ? column : 0
            length = index.zero? ? length : length - code.length
            code += str[from, length]

            break if code.length >= length
          end
          code
        end

        def data
          @data ||= ::File.read(path, encoding: Encoding::UTF_8)
        end

        # Function used to calculate the version hash for files and code parts.
        # @see http://www.cse.yorku.ca/~oz/hash.html#djb2
        def djb2a(str)
          str.each_byte.inject(5381) do |hash, b|
            ((hash << 5) + hash) ^ b
          end & 0xFFFFFFFF
        end
      end
    end
  end
end
