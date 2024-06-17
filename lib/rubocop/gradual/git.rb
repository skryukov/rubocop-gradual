# frozen_string_literal: true

require "rbconfig"

module RuboCop
  module Gradual
    # Git class handles git commands.
    module Git
      class << self
        def paths_by(commit)
          git_installed!

          case commit
          when :unstaged
            `git ls-files --others --exclude-standard -m`.split("\n")
          when :staged
            `git diff --cached --name-only --diff-filter=d`.split("\n") # excludes deleted files
          else
            `git diff --name-only #{commit}`.split("\n")
          end
        end

        private

        def git_installed!
          void = /msdos|mswin|djgpp|mingw/.match?(RbConfig::CONFIG["host_os"]) ? "NUL" : "/dev/null"
          git_found = `git --version >>#{void} 2>&1`

          raise Error, "Git is not found, please install it first." unless git_found
        end
      end
    end
  end
end
