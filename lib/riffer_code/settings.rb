# frozen_string_literal: true

require 'json'
require 'fileutils'

# Reads and writes the riffer-code user settings file at
# <tt>~/.riffer-code/settings.json</tt>.
#
# Example file:
#
#   {
#     "model": "anthropic/claude-sonnet-4-6",
#     "models": {
#       "anthropic/claude-sonnet-4-6": {
#         "input": 3.0,
#         "output": 15.0,
#         "cache_write": 3.75,
#         "cache_read": 0.3
#       }
#     }
#   }
#
# All keys are optional. Missing pricing means cost display is suppressed.
#
module RifferCode::Settings
  extend self

  PATH = File.expand_path('~/.riffer-code/settings.json')
  DEFAULT_MODEL = 'anthropic/claude-sonnet-4-6'

  # Returns the configured model string, or +DEFAULT_MODEL+ if not set.
  def model(path: PATH)
    read(path).fetch('model', DEFAULT_MODEL)
  end

  # Returns the pricing hash for +model+, or +nil+ if not configured.
  #
  # The returned hash has symbol keys +:input+, +:output+, +:cache_write+,
  # +:cache_read+ (all Float, USD per million tokens).
  def pricing_for(model, path: PATH)
    entry = read(path).dig('models', model)
    return nil unless entry

    {
      input: entry.fetch('input', 0).to_f,
      output: entry.fetch('output', 0).to_f,
      cache_write: entry.fetch('cache_write', 0).to_f,
      cache_read: entry.fetch('cache_read', 0).to_f
    }
  end

  private

  def read(path)
    return {} unless File.file?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    {}
  end
end
