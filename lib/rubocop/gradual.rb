# frozen_string_literal: true

require "rubocop"

require_relative "gradual/version"
require_relative "gradual/cli"

module RuboCop
  # RuboCop Gradual project namespace
  module Gradual
    class Error < StandardError; end

    class << self
      attr_accessor :debug, :exit_code, :mode, :path

      def set_defaults!
        self.debug = false
        self.exit_code = 0
        self.mode = :base
        self.path = ".rubocop_gradual.lock"
      end
    end

    set_defaults!
  end
end
