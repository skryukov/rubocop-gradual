# frozen_string_literal: true

require "diffy"

require_relative "serializer"

module RuboCop
  module Gradual
    # LockFile class handles reading and writing of lock file.
    class LockFile
      attr_reader :path

      def initialize(path)
        @path = path
      end

      def read_results
        return unless File.exist?(path)

        Serializer.deserialize(content)
      end

      def delete
        return unless File.exist?(path)

        File.delete(path)
      end

      def write_results(results)
        File.write(path, Serializer.serialize(results), encoding: Encoding::UTF_8)
      end

      def diff(new_results)
        Diffy::Diff.new(Serializer.serialize(new_results), content, context: 0)
      end

      private

      def content
        @content ||= File.exist?(path) ? File.read(path, encoding: Encoding::UTF_8) : ""
      end
    end
  end
end
