# frozen_string_literal: true

require 'json'
require 'fileutils'

module RifferCode::Credentials
  extend self

  PATH = File.expand_path('~/.riffer-code/auth.json')
  ENV_VAR = 'ANTHROPIC_API_KEY'
  PROVIDER = 'anthropic'

  def anthropic_api_key(path: PATH)
    from_env || from_file(path)
  end

  def save_anthropic_api_key(key, path: PATH)
    FileUtils.mkdir_p(File.dirname(path), mode: 0o700)
    data = read(path).merge(PROVIDER => key)
    # Create the file 0600 up front so the plaintext key is never briefly
    # world-readable (as File.write + chmod would leave it).
    File.open(path, File::WRONLY | File::CREAT | File::TRUNC, 0o600) do |file|
      file.write(JSON.pretty_generate(data))
    end
    key
  end

  private

  def from_env
    value = ENV.fetch(ENV_VAR, nil)
    value unless value.nil? || value.strip.empty?
  end

  def from_file(path)
    key = read(path)[PROVIDER]
    key unless key.nil? || key.strip.empty?
  end

  def read(path)
    return {} unless File.file?(path)

    JSON.parse(File.read(path))
  rescue JSON::ParserError
    {}
  end
end
