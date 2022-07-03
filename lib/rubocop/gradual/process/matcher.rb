# frozen_string_literal: true

module RuboCop
  module Gradual
    class Process
      # Matcher matches two files arrays and returns an object with matched map.
      class Matcher
        include Enumerable

        attr_reader :unmatched_keys, :unmatched_values, :matched

        def initialize(keys, values, matched)
          @unmatched_keys = keys - matched.keys
          @unmatched_values = values - matched.values
          @matched = matched
        end

        def each(&block)
          @matched.each(&block)
        end

        class << self
          def new(keys, values, property)
            matched = keys.each_with_object({}) do |key, result|
              match_value = values.find do |value|
                key.public_send(property) == value.public_send(property)
              end
              result[key] = match_value if match_value
            end

            super(keys, values, matched)
          end
        end
      end
    end
  end
end
