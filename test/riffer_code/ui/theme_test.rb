# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::UI::ThemeTest < Minitest::Test
  def test_paints_text_with_an_ansi_escape_when_enabled
    theme = RifferCode::UI::Theme.new(enabled: true)

    assert_includes theme.pink('hi'), "\e[38;2;"
  end

  def test_returns_raw_text_when_disabled
    theme = RifferCode::UI::Theme.new(enabled: false)

    assert_equal 'hi', theme.pink('hi')
  end

  def test_dim_is_a_passthrough_when_disabled
    theme = RifferCode::UI::Theme.new(enabled: false)

    assert_equal 'hi', theme.dim('hi')
  end

  def test_purple_is_a_passthrough_when_disabled
    assert_equal 'hi', RifferCode::UI::Theme.new(enabled: false).purple('hi')
  end

  def test_blue_is_a_passthrough_when_disabled
    assert_equal 'hi', RifferCode::UI::Theme.new(enabled: false).blue('hi')
  end

  def test_red_is_a_passthrough_when_disabled
    assert_equal 'hi', RifferCode::UI::Theme.new(enabled: false).red('hi')
  end

  def test_bold_is_a_passthrough_when_disabled
    assert_equal 'hi', RifferCode::UI::Theme.new(enabled: false).bold('hi')
  end

  def test_for_disables_colour_for_a_non_tty
    refute RifferCode::UI::Theme.for(StringIO.new).enabled
  end
end
