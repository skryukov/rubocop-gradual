# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog],
and this project adheres to [Semantic Versioning].

## [Unreleased]

## [0.3.6] - 2024-07-21

### Fixed

- Don't fail `--check` when no issues and no lock file present. ([@skryukov])

## [0.3.5] - 2024-06-24

### Added

- Add support for the RuboCop `--list` option. ([@skryukov])

### Fixed

- Respect files passed to RuboCop in required mode. ([@skryukov])
- Exclude deleted files when running `--staged`. ([@dmorgan-fa])
- Don't show "EVEN BETTER" instruction when all issues are fixed. ([@skryukov])

## [0.3.4] - 2023-10-26

### Fixed

- Use JSON.dump instead of to_json for stable results encoding. ([@skryukov])

## [0.3.3] - 2023-10-18

### Fixed

- Throw an error when the `--check` option is used and file hash is outdated. ([@skryukov])
- Wrap RuboCop errors to make output more pleasant. ([@skryukov])

## [0.3.2] - 2023-10-10

### Fixed

- Handle syntax errors in inspected files. ([@skryukov])

## [0.3.1] - 2022-11-29

### Fixed

- More straightforward way of including RuboCop patch for Require mode. ([@skryukov])

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

[@dmorgan-fa]: https://github.com/dmorgan-fa
[@skryukov]: https://github.com/skryukov

[Unreleased]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.6...HEAD
[0.3.6]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.4...v0.3.5
[0.3.4]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.3...v0.3.4
[0.3.3]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/skryukov/rubocop-gradual/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/skryukov/rubocop-gradual/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.1...v0.2.0
[0.1.1]: https://github.com/skryukov/rubocop-gradual/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/skryukov/rubocop-gradual/commits/v0.1.0

[Keep a Changelog]: https://keepachangelog.com/en/1.0.0/
[Semantic Versioning]: https://semver.org/spec/v2.0.0.html
