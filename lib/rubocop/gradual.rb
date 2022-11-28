# frozen_string_literal: true

require "rubocop"

require_relative "gradual/version"
require_relative "gradual/cli"

module RuboCop
  # RuboCop Gradual project namespace
  module Gradual
    class Error < StandardError; end
  end
end
