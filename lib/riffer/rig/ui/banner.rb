# frozen_string_literal: true

module Riffer::Rig::UI::Banner
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
    Riffer::Rig::UI::Palette::PINK,
    Riffer::Rig::UI::Palette::MAGENTA,
    Riffer::Rig::UI::Palette::PURPLE,
    Riffer::Rig::UI::Palette::BLUE,
    Riffer::Rig::UI::Palette::CYAN,
    Riffer::Rig::UI::Palette::CYAN
  ].freeze

  INFO_LABEL_WIDTH = 8
  INDENT = '  '
  BEAR_GAP = '  '

  def call(theme, model:, cwd:, context:, skills:, version:, glint_col: nil)
    lines(theme, model: model, cwd: cwd, context: context, skills: skills, version: version, glint_col: glint_col).join("\n")
  end

  def lines(theme, model:, cwd:, context:, skills:, version:, glint_col: nil)
    [''] + art(theme, glint_col: glint_col) + [''] +
      info(theme, model: model, cwd: cwd, context: context, skills: skills, version: version) + ['']
  end

  def art(theme, glint_col: nil)
    bear = Riffer::Rig::UI::Riffy.render(theme, glint_col: glint_col)
    right = WORDMARK.each_index.map { |i| theme.paint(WORDMARK[i], ROW_COLOURS[i]) }
    right += ['', "#{theme.grey('· code ·')}   #{theme.cyan("♪ let's riff ♪")}"]

    pad = (bear.length - right.length) / 2
    bear.each_index.map do |i|
      side = right[i - pad] if (pad...(pad + right.length)).cover?(i)
      "#{INDENT}#{bear[i]}#{BEAR_GAP}#{side}".rstrip
    end
  end

  def info(theme, model:, cwd:, context:, skills:, version:)
    rows = { model: model, cwd: cwd, context: context, skills: skills, version: version }.map do |label, value|
      "  #{theme.magenta('▸')} #{theme.grey(label.to_s.ljust(INFO_LABEL_WIDTH))}#{value}"
    end
    rows + ['', "  #{theme.dim('type /exit to quit')}"]
  end
end
