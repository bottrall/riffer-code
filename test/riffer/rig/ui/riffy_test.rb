# frozen_string_literal: true

require 'test_helper'

class Riffer::Rig::UI::RiffyTest < Minitest::Test
  def test_renders_one_character_row_per_two_pixel_rows
    rows = Riffer::Rig::UI::Riffy.render(Riffer::Rig::UI::Theme.new(enabled: false))

    assert_equal Riffer::Rig::UI::Riffy::HEIGHT, rows.length
  end

  def test_mono_render_has_no_escapes
    rows = Riffer::Rig::UI::Riffy.render(Riffer::Rig::UI::Theme.new(enabled: false))

    refute_includes rows.join, "\e["
  end

  def test_glint_changes_the_render_in_colour
    theme = Riffer::Rig::UI::Theme.new(enabled: true)

    refute_equal Riffer::Rig::UI::Riffy.render(theme), Riffer::Rig::UI::Riffy.render(theme, glint_col: Riffer::Rig::UI::Riffy::GLINT_COLS.first)
  end

  def test_equalizer_has_no_escapes_when_theme_disabled
    refute_includes Riffer::Rig::UI::Riffy.equalizer(Riffer::Rig::UI::Theme.new(enabled: false), 3), "\e["
  end
end
