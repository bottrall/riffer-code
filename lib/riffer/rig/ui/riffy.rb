# frozen_string_literal: true

# riffer-rig's mascot sprite, authored as a character grid (see LEGEND).
module Riffer::Rig::UI::Riffy
  extend self

  LEGEND = {
    '.' => nil,
    'D' => :outline,  # deep purple outline / shadow / nose
    'B' => :body,     # purple fur
    'M' => :shade,    # mid purple (inner ear, jaw shadow, leg lines)
    'L' => :light,    # light lilac (snout, paw pads)
    'K' => :shades,   # near-black sunglasses
    'W' => :glint     # lens glint (intro only)
  }.freeze

  PALETTE = {
    outline: [74, 46, 122],
    body: [157, 92, 232],
    shade: [120, 66, 190],
    light: [212, 180, 250],
    shades: [12, 10, 20],
    glint: [240, 240, 255]
  }.freeze

  GRID = [
    '...DDDD......DDDD...',
    '..DBBBBD....DBBBBD..',
    '..DBMMBD....DBMMBD..',
    '..DBMMBD....DBMMBD..',
    '..DBBDDDDDDDDDDBBD..',
    '...DBBBBBBBBBBBBD...',
    '...DKKKKKKKKKKKKD...',
    '...DKKKKKBBKKKKKD...',
    '...DBKKKBBBBKKKBD...',
    '...DBBBBBDDBBBBBD...',
    '...DBBBBLLLLBBBBD...',
    '...DBBBMLLLLMBBBD...',
    '....DBBBBBBBBBBD....',
    '....DDMMMMMMMMDD....',
    '.....DBBBBBBBBD.....',
    '....DBBBBBBBBBBD....',
    '...DBBBBBBBBBBBBD...',
    '..DBBBBBBBBBBBBBBD..',
    '.DBBBBBBBBBBBBBBBBD.',
    '.DBBBBDBBDDBBDBBBBD.',
    '.DLLLDDLLDDLLDDLLLD.'
  ].freeze

  WIDTH = GRID.first.length
  HEIGHT = (GRID.length + 1) / 2

  LENS_ROWS = [6, 7, 8].freeze
  GLINT_COLS = [4, 5, 6, 7, 8, 11, 12, 13, 14, 15].freeze

  EQ_LEVELS = '▁▂▃▄▅▆▇█'.chars.freeze
  EQ_BARS = 7

  def render(theme, glint_col: nil)
    sprite = GRID.map { |row| row.chars.map { |char| LEGEND.fetch(char) } }
    apply_glint(sprite, glint_col) if glint_col
    Riffer::Rig::UI::Pixels.render(sprite, PALETTE, theme)
  end

  def equalizer(theme, tick)
    bars = Array.new(EQ_BARS) do |i|
      height = (Math.sin((tick + i) * 0.6).abs * (EQ_LEVELS.length - 1)).round
      bar = EQ_LEVELS[height]
      i.even? ? theme.cyan(bar) : theme.magenta(bar)
    end
    "#{bars.join} #{theme.grey('riffing…')}"
  end

  private

  def apply_glint(sprite, column)
    LENS_ROWS.each do |row|
      sprite[row][column] = :glint if sprite[row][column] == :shades
    end
  end
end
