module Overcommit::Hook::PreCommit
  # Runs `pyflakes` against any modified Python files.
  class Pyflakes < Base
    MESSAGE_REGEX = /^(?<file>[^:]+):(?<line>\d+):/

    def run
      result = execute(command + applicable_files)
      return :pass if result.success?

      errors = get_messages(result.stderr, :error)
      warnings = get_messages(result.stdout, :warning)

      errors + warnings
    end

    private

    def get_messages(output, type)
      # example message:
      #   path/to/file.py:57: local variable 'x' is assigned to but never used
      extract_messages(
        output.split("\n").grep(MESSAGE_REGEX),
        MESSAGE_REGEX,
        proc { type }
      )
    end
  end
end
