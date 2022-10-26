# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

## [0.3.0] - 2022-10-26

### Added

- Partial linting (experimental). ([@skryukov])
  
  Partial linting is useful when you want to run RuboCop Gradual on a subset of files, for example, on changed files in a pull request:

```shell
rubocop-gradual path/to/file # run `rubocop-gradual` on a subset of files
rubocop-gradual --staged # run `rubocop-gradual` on staged files
rubocop-gradual --unstaged # run `rubocop-gradual` on unstaged files
rubocop-gradual --commit origin/main # run `rubocop-gradual` on changed files since the commit

# it's possible to combine options with autocorrect:
rubocop-gradual --staged --autocorrect # run `rubocop-gradual` with autocorrect on staged files
```

- Require mode (experimental). ([@skryukov])

  RuboCop Gradual can be used in "Require mode", which is a way to replace `rubocop` with `rubocop-gradual`:

```yaml
# .rubocop.yml

require:
  - rubocop-gradual
```

- Built-in Rake tasks. ([@skryukov])

```ruby
# Rakefile
require "rubocop/gradual/rake_task"

RuboCop::Gradual::RakeTask.new
```

### Fixed

- Issues with the same location ordered by the message. ([@skryukov])

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

[Unreleased]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/skryukov/rubocop-gradual/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/skryukov/rubocop-gradual/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
