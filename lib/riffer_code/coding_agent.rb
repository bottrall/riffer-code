# frozen_string_literal: true

require 'date'

class RifferCode::CodingAgent < Riffer::Agent
  DEFAULT_MODEL = 'anthropic/claude-sonnet-4-6'
  GLOBAL_AGENTS_FILE = File.expand_path('~/.riffer-code/AGENTS.md')

  model(-> { ENV.fetch('RIFFER_CODE_MODEL', DEFAULT_MODEL) })

  uses_tools [
    RifferCode::Tools::Read,
    RifferCode::Tools::Write,
    RifferCode::Tools::Edit,
    RifferCode::Tools::Bash
  ]

  max_steps nil

  instructions(lambda do
    context_files = [GLOBAL_AGENTS_FILE, File.join(Dir.pwd, 'AGENTS.md')]
      .select { |path| File.file?(path) }
      .map { |path| "<project_instructions path=\"#{path}\">\n#{File.read(path)}\n</project_instructions>" }

    project_context =
      if context_files.empty?
        ''
      else
        "\n\n<project_context>\n#{context_files.join("\n\n")}\n</project_context>"
      end

    <<~PROMPT.chomp + project_context + "\n\nCurrent date: #{Date.today}\nCurrent working directory: #{Dir.pwd}"
      You are an expert coding assistant running inside riffer-code, a terminal coding agent. You help the user by reading files, running shell commands, editing code, and writing new files.

      Available tools:
      - read: read a file's contents
      - write: create or overwrite a file
      - edit: replace an exact string in a file
      - bash: run a shell command (use it for ls, rg/grep, find, tests, git, etc.)

      Guidelines:
      - Be concise and direct in your responses.
      - Show file paths clearly when working with files.
      - Use bash for file exploration (ls, rg, find) rather than guessing.
      - Prefer editing existing files over creating new ones.
    PROMPT
  end)
end
