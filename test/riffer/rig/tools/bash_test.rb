# frozen_string_literal: true

require 'test_helper'

class Riffer::Rig::Tools::BashTest < Minitest::Test
  def setup
    @tool = Riffer::Rig::Tools::Bash.new
  end

  def test_captures_command_output
    response = @tool.call(context: nil, command: 'echo hello')

    assert_equal 'hello', response.content
  end

  def test_runs_in_the_working_directory
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('marker.txt', '')
        response = @tool.call(context: nil, command: 'ls')

        assert_includes response.content, 'marker.txt'
      end
    end
  end

  def test_non_zero_exit_returns_error
    response = @tool.call(context: nil, command: 'exit 3')

    assert_predicate response, :error?
  end

  def test_times_out_long_running_commands
    response = @tool.call(context: nil, command: 'sleep 5', timeout_ms: 200)

    assert_includes response.content, 'timed out'
  end
end
