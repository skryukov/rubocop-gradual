# frozen_string_literal: true

require "parallel"

require_relative "results/file"

module RuboCop
  module Gradual
    # Results is a collection of FileResults.
    class Results
      attr_reader :files

      def initialize(files:)
        @files = Parallel.map(files) { |file| File.new(**file) }.sort
      end
    end
  end
end
