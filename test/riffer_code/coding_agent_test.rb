# frozen_string_literal: true

require 'test_helper'

class RifferCode::CodingAgentTest < Minitest::Test
  def test_wraps_present_project_agents_file_in_the_system_prompt
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('AGENTS.md', 'ALWAYS_SQUAWK')
        agent = RifferCode::CodingAgent.new

        assert_includes agent.instruction_message.content, '<project_instructions'
      end
    end
  end

  def test_includes_project_agents_file_content
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('AGENTS.md', 'ALWAYS_SQUAWK')
        agent = RifferCode::CodingAgent.new

        assert_includes agent.instruction_message.content, 'ALWAYS_SQUAWK'
      end
    end
  end

  def test_skips_a_missing_project_agents_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        agent = RifferCode::CodingAgent.new

        refute_includes agent.instruction_message.content, File.join(dir, 'AGENTS.md')
      end
    end
  end

  def test_runs_a_turn_against_the_mock_provider
    with_model('mock/claude-test') do
      response = RifferCode::CodingAgent.new.generate('hello')

      assert_equal 'Mock response', response.content
    end
  end

  private

  def with_model(model)
    previous = ENV.fetch('RIFFER_CODE_MODEL', nil)
    ENV['RIFFER_CODE_MODEL'] = model
    yield
  ensure
    ENV['RIFFER_CODE_MODEL'] = previous
  end
end
