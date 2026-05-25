# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::CLITest < Minitest::Test
  def test_start_runs_a_session_and_returns_zero
    with_clean_global_state do
      ENV['ANTHROPIC_API_KEY'] = 'sk-ant-test'

      exit_code = RifferCode::CLI.start(output: StringIO.new, input: StringIO.new(''))

      assert_equal 0, exit_code
    end
  end

  private

  # CLI.start mutates the global Riffer config (anthropic API key) and reads
  # ENV; snapshot and restore both so the test leaves no residue.
  def with_clean_global_state
    previous_key = Riffer.config.anthropic.api_key
    previous_env = ENV.fetch('ANTHROPIC_API_KEY', nil)
    yield
  ensure
    Riffer.config.anthropic.api_key = previous_key
    ENV['ANTHROPIC_API_KEY'] = previous_env
  end
end
