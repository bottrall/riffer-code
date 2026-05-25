# frozen_string_literal: true

require 'zeitwerk'
require 'riffer'
require_relative 'riffer_code/version'

module RifferCode; end

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/riffer_code", namespace: RifferCode)
loader.ignore("#{__dir__}/riffer_code/version.rb")
loader.inflector.inflect('cli' => 'CLI', 'repl' => 'REPL', 'ui' => 'UI')
loader.setup
