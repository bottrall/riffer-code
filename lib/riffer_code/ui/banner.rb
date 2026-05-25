# frozen_string_literal: true

module RifferCode::UI::Banner
  extend self

  WORDMARK = [
    '██████╗ ██╗███████╗███████╗███████╗██████╗ ',
    '██╔══██╗██║██╔════╝██╔════╝██╔════╝██╔══██╗',
    '██████╔╝██║█████╗  █████╗  █████╗  ██████╔╝',
    '██╔══██╗██║██╔══╝  ██╔══╝  ██╔══╝  ██╔══██╗',
    '██║  ██║██║██║     ██║     ███████╗██║  ██║',
    '╚═╝  ╚═╝╚═╝╚═╝     ╚═╝     ╚══════╝╚═╝  ╚═╝'
  ].freeze

  ROW_COLOURS = [
    RifferCode::UI::Palette::PINK,
    RifferCode::UI::Palette::MAGENTA,
    RifferCode::UI::Palette::PURPLE,
    RifferCode::UI::Palette::BLUE,
    RifferCode::UI::Palette::CYAN,
    RifferCode::UI::Palette::CYAN
  ].freeze

  INFO_LABEL_WIDTH = 8
  INDENT = '  '
  BEAR_GAP = '  '

  def call(theme, model:, cwd:, context:, version:, glint_col: nil)
    lines(theme, model: model, cwd: cwd, context: context, version: version, glint_col: glint_col).join("\n")
  end

  def lines(theme, model:, cwd:, context:, version:, glint_col: nil)
    [''] + art(theme, glint_col: glint_col) + [''] +
      info(theme, model: model, cwd: cwd, context: context, version: version) + ['']
  end

  def art(theme, glint_col: nil)
    bear = RifferCode::UI::Riffy.render(theme, glint_col: glint_col)
    right = WORDMARK.each_index.map { |i| theme.paint(WORDMARK[i], ROW_COLOURS[i]) }
    right += ['', "#{theme.grey('· code ·')}   #{theme.cyan("♪ let's riff ♪")}"]

    pad = (bear.length - right.length) / 2
    bear.each_index.map do |i|
      side = right[i - pad] if (pad...(pad + right.length)).cover?(i)
      "#{INDENT}#{bear[i]}#{BEAR_GAP}#{side}".rstrip
    end
  end

  def info(theme, model:, cwd:, context:, version:)
    rows = { model: model, cwd: cwd, context: context, version: version }.map do |label, value|
      "  #{theme.magenta('▸')} #{theme.grey(label.to_s.ljust(INFO_LABEL_WIDTH))}#{value}"
    end
    rows + ['', "  #{theme.dim('type /exit to quit')}"]
  end
end
