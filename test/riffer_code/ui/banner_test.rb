# frozen_string_literal: true

require 'test_helper'

class RifferCode::UI::BannerTest < Minitest::Test
  def setup
    @theme = RifferCode::UI::Theme.new(enabled: false)
  end

  def test_includes_the_provided_info_values
    banner = RifferCode::UI::Banner.call(@theme, model: 'anthropic/claude-x', cwd: '/tmp/proj', context: 'AGENTS.md', version: '9.9.9')

    assert_includes banner, '/tmp/proj'
  end

  def test_includes_the_model
    banner = RifferCode::UI::Banner.call(@theme, model: 'anthropic/claude-x', cwd: '/tmp/proj', context: 'none', version: '9.9.9')

    assert_includes banner, 'anthropic/claude-x'
  end

  def test_emits_no_ansi_escapes_when_theme_disabled
    banner = RifferCode::UI::Banner.call(@theme, model: 'm', cwd: 'c', context: 'none', version: '1')

    refute_includes banner, "\e["
  end
end
