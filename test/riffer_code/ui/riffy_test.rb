# frozen_string_literal: true

require 'test_helper'

class RifferCode::UI::RiffyTest < Minitest::Test
  def test_renders_one_character_row_per_two_pixel_rows
    rows = RifferCode::UI::Riffy.render(RifferCode::UI::Theme.new(enabled: false))

    assert_equal RifferCode::UI::Riffy::HEIGHT, rows.length
  end

  def test_mono_render_has_no_escapes
    rows = RifferCode::UI::Riffy.render(RifferCode::UI::Theme.new(enabled: false))

    refute_includes rows.join, "\e["
  end

  def test_glint_changes_the_render_in_colour
    theme = RifferCode::UI::Theme.new(enabled: true)

    refute_equal RifferCode::UI::Riffy.render(theme), RifferCode::UI::Riffy.render(theme, glint_col: RifferCode::UI::Riffy::GLINT_COLS.first)
  end

  def test_equalizer_has_no_escapes_when_theme_disabled
    refute_includes RifferCode::UI::Riffy.equalizer(RifferCode::UI::Theme.new(enabled: false), 3), "\e["
  end
end
