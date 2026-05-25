# frozen_string_literal: true

# +enabled+ gates every escape so the same code path emits plain, escape-free
# text when piped or tested.
RifferCode::UI::Theme = Data.define(:enabled)

# Behaviour lives in a reopened class (rather than the `Data.define` block) so
# the type checker can analyse the methods.
class RifferCode::UI::Theme
  def self.for(io)
    new(enabled: io.respond_to?(:tty?) && io.tty? && !ENV.key?('NO_COLOR'))
  end

  def paint(text, rgb)
    return text.to_s unless enabled

    "\e[38;2;#{rgb[0]};#{rgb[1]};#{rgb[2]}m#{text}\e[0m"
  end

  def pink(text) = paint(text, RifferCode::UI::Palette::PINK)

  def magenta(text) = paint(text, RifferCode::UI::Palette::MAGENTA)

  def purple(text) = paint(text, RifferCode::UI::Palette::PURPLE)

  def blue(text) = paint(text, RifferCode::UI::Palette::BLUE)

  def cyan(text) = paint(text, RifferCode::UI::Palette::CYAN)

  def grey(text) = paint(text, RifferCode::UI::Palette::GREY)

  def red(text) = paint(text, RifferCode::UI::Palette::RED)

  def dim(text)
    return text.to_s unless enabled

    "\e[2m#{text}\e[0m"
  end

  def bold(text)
    return text.to_s unless enabled

    "\e[1m#{text}\e[0m"
  end
end
