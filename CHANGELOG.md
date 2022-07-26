# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

### Added

- Built-in Rake tasks. ([@skryukov])
```ruby
# Rakefile
require "rubocop/gradual/rake_task"

RuboCop::Gradual::RakeTask.new
```

## [0.2.0] - 2022-07-26

### Added

- Autocorrection options. ([@skryukov])
  Run `rubocop-gradual -a` and `rubocop-gradual -A` to autocorrect new and changed files and then update the lock file.

### Changed

- Rename `--ci` to `--check` option. ([@skryukov])

- Rename `-u, --update` to `-U, --force-update` option. ([@skryukov])

## [0.1.1] - 2022-07-05

### Changed

- `parallel` gem is used to speed up results parsing. ([@skryukov])

### Fixed

- Fixed multiline issues hash calculation. ([@skryukov])

## [0.1.0] - 2022-07-03

### Added

- Initial implementation. ([@skryukov])

[@skryukov]: https://github.com/skryukov

[Unreleased]: https://github.com/skryukov/rubocop-gradual/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/skryukov/rubocop-gradual/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
