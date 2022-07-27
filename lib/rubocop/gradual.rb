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

if ENV["NO_GRADUAL"] != "1" && (RuboCop::ConfigLoader.loaded_features & %w[rubocop-gradual rubocop/gradual]).any?
  require_relative "gradual/patch"
  RuboCop::CLI.prepend(RuboCop::Gradual::Patch)
end
