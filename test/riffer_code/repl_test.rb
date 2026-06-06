# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::REPLTest < Minitest::Test
  def test_run_exits_on_empty_input_and_prints_the_sign_off
    output = StringIO.new
    theme = RifferCode::UI::Theme.new(enabled: false)
    renderer = RifferCode::UI::Renderer.new(io: output, theme: theme)
    repl = RifferCode::REPL.new(agent: RifferCode::CodingAgent.new, renderer: renderer, input: StringIO.new(''), output: output, theme: theme)

    repl.run

    assert_includes output.string, 'next riff'
  end

  def test_skill_command_activates_skill_and_prints_confirmation
    with_skill('refactor') do |agent, output|
      repl = build_repl(agent, output, "/refactor\n")

      repl.run

      assert_includes output.string, 'skill: refactor'
    end
  end

  def test_skill_command_marks_skill_as_activated_on_agent
    with_skill('refactor') do |agent, output|
      repl = build_repl(agent, output, "/refactor\n")

      repl.run

      assert agent.context.skills.activated?('refactor')
    end
  end

  def test_skill_token_at_start_of_prompt_activates_skill
    with_skill('refactor') do |agent, output|
      repl = build_repl(agent, output, "/refactor please clean up this file\n")

      repl.run

      assert_includes output.string, 'skill: refactor'
    end
  end

  def test_skill_token_at_end_of_prompt_activates_skill
    with_skill('refactor') do |agent, output|
      repl = build_repl(agent, output, "please clean up this file /refactor\n")

      repl.run

      assert_includes output.string, 'skill: refactor'
    end
  end

  def test_skill_token_mid_prompt_activates_skill
    with_skill('refactor') do |agent, output|
      repl = build_repl(agent, output, "please /refactor this file\n")

      repl.run

      assert_includes output.string, 'skill: refactor'
    end
  end

  def test_multiple_skill_tokens_activate_first_skill
    with_skill('refactor') do |agent, _|
      with_skill('code-review', agent: agent) do |_, output|
        repl = build_repl(agent, output, "/refactor /code-review\n")

        repl.run

        assert agent.context.skills.activated?('refactor')
      end
    end
  end

  def test_multiple_skill_tokens_activate_second_skill
    with_skill('refactor') do |agent, _|
      with_skill('code-review', agent: agent) do |_, output|
        repl = build_repl(agent, output, "/refactor /code-review\n")

        repl.run

        assert agent.context.skills.activated?('code-review')
      end
    end
  end

  def test_multiple_skill_tokens_print_confirmation_for_first
    with_skill('refactor') do |agent, _|
      with_skill('code-review', agent: agent) do |_, output|
        repl = build_repl(agent, output, "/refactor /code-review\n")

        repl.run

        assert_includes output.string, 'skill: refactor'
      end
    end
  end

  def test_multiple_skill_tokens_print_confirmation_for_second
    with_skill('refactor') do |agent, _|
      with_skill('code-review', agent: agent) do |_, output|
        repl = build_repl(agent, output, "/refactor /code-review\n")

        repl.run

        assert_includes output.string, 'skill: code-review'
      end
    end
  end

  def test_unrecognised_slash_token_produces_no_output
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        output = StringIO.new
        agent = RifferCode::CodingAgent.new
        repl = build_repl(agent, output, "/no-such-skill\n")

        repl.run

        refute_includes output.string, 'skill:'
      end
    end
  end

  def test_exit_command_exits_the_repl
    output = StringIO.new
    repl = build_repl(RifferCode::CodingAgent.new, output, "/exit\n")

    repl.run

    assert_includes output.string, 'next riff'
  end

  def test_exit_command_is_not_treated_as_skill_command
    output = StringIO.new
    repl = build_repl(RifferCode::CodingAgent.new, output, "/exit\n")

    repl.run

    refute_includes output.string, 'skill:'
  end

  private

  def build_repl(agent, output, input_str)
    theme = RifferCode::UI::Theme.new(enabled: false)
    renderer = RifferCode::UI::Renderer.new(io: output, theme: theme)
    RifferCode::REPL.new(agent: agent, renderer: renderer, input: StringIO.new(input_str), output: output, theme: theme)
  end

  def with_skill(name, agent: nil, &block)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        skill_dir = File.join(dir, '.skills', name)
        FileUtils.mkdir_p(skill_dir)
        File.write(File.join(skill_dir, 'SKILL.md'), <<~MD)
          ---
          name: #{name}
          description: A test skill named #{name}.
          ---
          You are the #{name} assistant.
        MD

        output = StringIO.new
        agent ||= RifferCode::CodingAgent.new
        yield(agent, output)
      end
    end
  end
end
