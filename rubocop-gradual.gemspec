# frozen_string_literal: true

require_relative "lib/rubocop/gradual/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-gradual"
  spec.version = RuboCop::Gradual::VERSION
  spec.authors = ["Svyatoslav Kryukov"]
  spec.email = ["s.g.kryukov@yandex.ru"]

  spec.summary = "Gradual RuboCop plugin"
  spec.description = "Gradually improve your code with RuboCop."
  spec.homepage = "https://github.com/skryukov/rubocop-gradual"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata = {
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "documentation_uri" => "#{spec.homepage}/blob/main/README.md",
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "rubygems_mfa_required" => "true"
  }

  spec.bindir = "exe"
  spec.executables = ["rubocop-gradual"]
  spec.files = Dir.glob("lib/**/*") + %w[exe/rubocop-gradual README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ["lib"]

  spec.add_dependency "diff-lcs", ">= 1.2.0", "< 2.0"
  spec.add_dependency "diffy", "~> 3.0"
  spec.add_dependency "parallel", "~> 1.10"
  spec.add_dependency "rainbow", ">= 2.2.2", "< 4.0"
  spec.add_dependency "rubocop", "~> 1.0"
end
