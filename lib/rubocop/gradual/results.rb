# frozen_string_literal: true

require_relative "results/file"

module RuboCop
  module Gradual
    # Results is a collection of FileResults.
    class Results
      attr_reader :files

      def initialize(files:)
        @files = files.map { |file| File.new(**file) }.sort
      end
    end
  end
end
