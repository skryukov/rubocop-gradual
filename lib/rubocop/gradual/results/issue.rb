# frozen_string_literal: true

module RuboCop
  module Gradual
    class Results
      # IssueResults is a representation of an issue in a Gradual results.
      class Issue
        attr_reader :line, :column, :length, :message, :code_hash

        def initialize(line:, column:, length:, message:, hash:)
          @line = line
          @column = column
          @length = length
          @message = message
          @code_hash = hash
        end

        def <=>(other)
          [line, column, length, message] <=> [other.line, other.column, other.length, other.message]
        end

        def to_s
          "[#{[line, column, length, message.to_json, code_hash].join(", ")}]"
        end

        def ==(other)
          line == other.line && column == other.column && length == other.length && code_hash == other.code_hash
        end

        def distance(other)
          [(line - other.line).abs, (column - other.column).abs]
        end
      end
    end
  end
end
