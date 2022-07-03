# frozen_string_literal: true

module RuboCop
  module Gradual
    # Serializer is a module used to serialize and deserialize RuboCop results to the lock file.
    module Serializer
      class << self
        def serialize(results)
          "#{serialize_files(results.files)}\n"
        end

        def deserialize(data)
          files = JSON.parse(data).map do |key, value|
            path, hash = key.split(":")
            raise Error, "Wrong format of the lock file: `#{key}` must include hash" if hash.nil? || hash.empty?

            issues = value.map do |line, column, length, message, issue_hash|
              { line: line, column: column, length: length, message: message, hash: issue_hash }
            end
            { path: path, hash: hash.to_i, issues: issues }
          end
          Results.new(files: files)
        end

        private

        def serialize_files(files)
          data = files.map do |file|
            key = "#{file.path}:#{file.file_hash}"
            issues = serialize_issues(file.issues)
            [key, issues]
          end
          key_values_to_json(data)
        end

        def serialize_issues(issues)
          "[\n#{indent(issues.join(",\n"))}\n]"
        end

        def key_values_to_json(arr)
          arr.map { |key, value| indent(%("#{key}": #{value})) }
             .join(",\n")
             .then { |data| "{\n#{data}\n}" }
        end

        def indent(str, indent_str = "  ")
          str.lines
             .map { |line| indent_str + line }
             .join
        end
      end
    end
  end
end
