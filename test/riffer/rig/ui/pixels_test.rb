# frozen_string_literal: true

require 'test_helper'

class Riffer::Rig::UI::PixelsTest < Minitest::Test
  PALETTE = { a: [255, 0, 0], b: [0, 255, 0] }.freeze

  def test_collapses_two_pixel_rows_into_one_character_row
    sprite = [%i[a a], %i[b b], [:a, nil], [nil, nil]]

    assert_equal 2, Riffer::Rig::UI::Pixels.render(sprite, PALETTE, Riffer::Rig::UI::Theme.new(enabled: false)).length
  end

  def test_transparent_pixels_render_as_spaces
    sprite = [[nil, nil], [nil, nil]]

    assert_equal ['  '], Riffer::Rig::UI::Pixels.render(sprite, PALETTE, Riffer::Rig::UI::Theme.new(enabled: false))
  end

  def test_mono_render_has_no_escapes
    sprite = [%i[a b], %i[b a]]

    refute_includes Riffer::Rig::UI::Pixels.render(sprite, PALETTE, Riffer::Rig::UI::Theme.new(enabled: false)).join, "\e["
  end

  def test_colour_render_emits_truecolor_escapes
    sprite = [[:a], [:b]]

    assert_includes Riffer::Rig::UI::Pixels.render(sprite, PALETTE, Riffer::Rig::UI::Theme.new(enabled: true)).join, "\e[38;2;"
  end
end
