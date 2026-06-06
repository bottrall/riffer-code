# frozen_string_literal: true

require 'test_helper'

class RifferCode::UI::BannerTest < Minitest::Test
  def setup
    @theme = RifferCode::UI::Theme.new(enabled: false)
  end

  def test_includes_the_provided_info_values
    banner = RifferCode::UI::Banner.call(@theme, model: 'anthropic/claude-x', cwd: '/tmp/proj', context: 'AGENTS.md', skills: '2', version: '9.9.9')

    assert_includes banner, '/tmp/proj'
  end

  def test_includes_the_model
    banner = RifferCode::UI::Banner.call(@theme, model: 'anthropic/claude-x', cwd: '/tmp/proj', context: 'none', skills: 'none', version: '9.9.9')

    assert_includes banner, 'anthropic/claude-x'
  end

  def test_includes_the_skills_label
    banner = RifferCode::UI::Banner.call(@theme, model: 'm', cwd: 'c', context: 'none', skills: '3', version: '1')

    assert_includes banner, 'skills'
  end

  def test_includes_the_skills_count
    banner = RifferCode::UI::Banner.call(@theme, model: 'm', cwd: 'c', context: 'none', skills: '3', version: '1')

    assert_includes banner, '3'
  end

  def test_shows_none_when_no_skills
    banner = RifferCode::UI::Banner.call(@theme, model: 'm', cwd: 'c', context: 'none', skills: 'none', version: '1')

    assert_includes banner, 'none'
  end

  def test_emits_no_ansi_escapes_when_theme_disabled
    banner = RifferCode::UI::Banner.call(@theme, model: 'm', cwd: 'c', context: 'none', skills: 'none', version: '1')

    refute_includes banner, "\e["
  end
end
