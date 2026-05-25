# frozen_string_literal: true

# Each character cell stacks two vertical pixels via half-block glyphs (▀ top,
# ▄ bottom): the foreground colours the top pixel and the background the bottom,
# doubling vertical resolution. A disabled theme falls back to plain block
# glyphs so piped/non-colour output stays escape-free.
module RifferCode::UI::Pixels
  extend self

  RESET = "\e[0m"

  def render(sprite, palette, theme)
    sprite.each_slice(2).map do |top, bottom|
      render_row(top, bottom || [], palette, theme)
    end
  end

  private

  def render_row(top, bottom, palette, theme)
    width = [top.length, bottom.length].max
    (0...width).map { |x| cell(palette[top[x]], palette[bottom[x]], theme) }.join
  end

  def cell(top_rgb, bottom_rgb, theme)
    return ' ' if top_rgb.nil? && bottom_rgb.nil?

    unless theme.enabled
      return '█' if top_rgb && bottom_rgb
      return '▀' if top_rgb

      return '▄'
    end

    if top_rgb && bottom_rgb
      "#{fg(top_rgb)}#{bg(bottom_rgb)}▀#{RESET}"
    elsif top_rgb
      "#{fg(top_rgb)}▀#{RESET}"
    else
      "#{fg(bottom_rgb)}▄#{RESET}"
    end
  end

  def fg(rgb) = "\e[38;2;#{rgb[0]};#{rgb[1]};#{rgb[2]}m"

  def bg(rgb) = "\e[48;2;#{rgb[0]};#{rgb[1]};#{rgb[2]}m"
end
