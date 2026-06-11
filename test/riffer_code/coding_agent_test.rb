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
    response = mock_agent.generate('hello')

    assert_equal 'Mock response', response.content
  end

  def test_excludes_skill_activate_tool_when_no_skills_are_present
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        agent = isolated_agent(global_dir: dir, project_dir: dir)

        refute_includes agent.tools.map(&:name), 'skill_activate'
      end
    end
  end

  def test_includes_skill_activate_tool_when_skills_are_present
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        skill_dir = File.join(dir, '.skills', 'test-skill')
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, 'SKILL.md'), <<~MD)
          ---
          name: test-skill
          description: A test skill.
          ---
          You are a test skill.
        MD

        # Point the backend at the .skills dir so it finds test-skill.
        agent = isolated_agent(global_dir: dir, project_dir: File.join(dir, '.skills'))

        assert_includes agent.tools.map(&:name), 'skill_activate'
      end
    end
  end

  def test_loads_skills_from_project_skills_dir
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        skill_dir = File.join(dir, '.skills', 'refactor')
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, 'SKILL.md'), <<~MD)
          ---
          name: refactor
          description: Refactors code for clarity and maintainability.
          ---
          You are a refactoring assistant.
        MD

        agent = mock_agent
        agent.generate('hello')

        skills_msg = agent.session.messages.grep(Riffer::Messages::System)
                          .find { |m| m.content.include?('refactor') }

        refute_nil skills_msg
      end
    end
  end

  def test_uses_xml_adapter_for_claude_models
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        skill_dir = File.join(dir, '.skills', 'refactor')
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, 'SKILL.md'), <<~MD)
          ---
          name: refactor
          description: Refactors code for clarity and maintainability.
          ---
          You are a refactoring assistant.
        MD

        agent = mock_agent(model: 'mock/claude-sonnet-4-6')
        agent.generate('hello')

        skills_msg = agent.session.messages.grep(Riffer::Messages::System)
                          .find { |m| m.content.include?('<available_skills>') }

        refute_nil skills_msg
      end
    end
  end

  private

  def mock_agent(model: 'mock/claude-test')
    config = RifferCode::CodingAgent.config.dup
    config.model = model
    RifferCode::CodingAgent.new(config: config)
  end

  # Builds an agent with a skills backend isolated to +global_dir+ and
  # +project_dir+, preventing the real ~/.riffer-code/skills from influencing
  # tool registration in tests.
  def isolated_agent(global_dir:, project_dir:)
    config = RifferCode::CodingAgent.config.dup
    config.skills_config = Riffer::Skills::Config.new.tap do |sc|
      sc.backend(Riffer::Skills::FilesystemBackend.new(global_dir, project_dir))
    end
    RifferCode::CodingAgent.new(config: config)
  end
end
