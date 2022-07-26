# RuboCop Gradual

[![Gem Version](https://badge.fury.io/rb/rubocop-gradual.svg)](https://rubygems.org/gems/rubocop-gradual)
[![Build](https://github.com/skryukov/rubocop-gradual/workflows/Build/badge.svg)](https://github.com/skryukov/rubocop-gradual/actions)

RuboCop Gradual is a tool that helps track down and fix RuboCop offenses in your code gradually. It's a more flexible alternative to RuboCop's `--auto-gen-config` option.

RuboCop Gradual:

- generates the lock file with all RuboCop offenses and uses hashes to track each offense **line by line**
- **automatically** updates the lock file on every successful run, but returns errors on new offenses
- does not prevent your editor from **showing ignored offenses**

Gain full control of gradual improvements: just add `rubocop-gradual` and use it as proxy for `rubocop`.

<a href="https://evilmartians.com/?utm_source=rubocop-gradual&utm_campaign=project_page">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
</a>

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add rubocop-gradual

Run RuboCop Gradual to create a lock file (defaults to `.rubocop_gradual.lock`):

    $ rubocop-gradual

Commit the lock file to the project repository to keep track of all non-fixed offenses.

Run `rubocop-gradual` before commiting changes to update the lock file. RuboCop Gradual will keep updating the lock file to keep track of all non-fixed offenses, but it will throw an error if there are any new offenses. 

## Usage

Proposed workflow:

- Remove `rubocop_todo.yml` if it exists.
- Run `rubocop-gradual` to generate a lock file and commit it to the project repository.
- Add `rubocop-gradual --check` to your CI pipeline instead of `rubocop`/`standard`. It will throw an error if the lock file is out of date.
- Run `rubocop-gradual` to update the lock file, or `rubocop-gradual -a` to run autocorrection for all new and changed files and then update the lock file.
- Optionally, add `rubocop-gradual` as a pre-commit hook to your repository (using [lefthook], for example).
- RuboCop Gradual will throw an error on any new offense, but if you really want to force update the lock file, run `rubocop-gradual --force-update`.

## Available options

```
    -U, --force-update               Force update Gradual lock file.
        --check                      Check Gradual lock file is up-to-date.
    -a, --autocorrect                Autocorrect offenses (only when it's safe).
    -A, --autocorrect-all            Autocorrect offenses (safe and unsafe).
        --gradual-file FILE          Specify Gradual lock file.
    -v, --version                    Display version.
    -h, --help                       Prints this help.
```

## Rake tasks

To use built-in Rake tasks add the following to your Rakefile:

```ruby
# Rakefile
require "rubocop/gradual/rake_task"

RuboCop::Gradual::RakeTask.new
```

This will add rake tasks:

```
bundle exec rake -T
rake rubocop_gradual                  # Run RuboCop Gradual
rake rubocop_gradual:autocorrect      # Run RuboCop Gradual with autocorrect (only when it's safe)
rake rubocop_gradual:autocorrect_all  # Run RuboCop Gradual with autocorrect (safe and unsafe)
rake rubocop_gradual:check            # Run RuboCop Gradual to check the lock file
rake rubocop_gradual:force_update     # Run RuboCop Gradual to force update the lock file
```

It's possible to customize the Rake task name and options:

```ruby
# Rakefile

require "rubocop/gradual/rake_task"

RuboCop::Gradual::RakeTask.new(:custom_task_name) do |task|
  task.options = %w[--gradual-file custom_gradual_file.lock]
  task.verbose = false
end
```

## Alternatives

- [RuboCop TODO file]. Comes out of the box with RuboCop. Provides a way to ignore offenses on the file level, which is problematic since it is possible to introduce new offenses without any signal from linter.
- [Pronto]. Checks for offenses only on changed files. Does not provide a way to temporarily ignore offenses.
- [Betterer]. Universal test runner that helps make incremental improvements witten in JavaScript. RuboCop Gradual is highly inspired by Betterer.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/skryukov/rubocop-gradual

## License

The gem is available as open source under the terms of the [MIT License].

[lefthook]: https://github.com/evilmartians/lefthook
[RuboCop TODO file]: https://docs.rubocop.org/rubocop/configuration.html#automatically-generated-configuration
[Pronto]: https://github.com/prontolabs/pronto-rubocop
[Betterer]: https://github.com/phenomnomnominal/betterer
[MIT License]: https://opensource.org/licenses/MIT
