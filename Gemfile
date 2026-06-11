# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in rubocop-gradual.gemspec
gemspec

gem "rake", "~> 13.0"

gem "rspec", "~> 3.0"

gem "rubocop-performance"
gem "rubocop-rake"
gem "rubocop-rspec"

# Standard pins exact RuboCop versions, so only install it on Rubies
# where its RuboCop requirement matches the version under test.
gem "standard", ">= 1.50" if RUBY_VERSION >= "3.0"
