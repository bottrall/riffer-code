# frozen_string_literal: true

require 'zeitwerk'
require 'riffer'
require_relative 'rig/version'

loader = Zeitwerk::Loader.for_gem_extension(Riffer)
loader.ignore("#{__dir__}/rig/version.rb")
loader.inflector.inflect('cli' => 'CLI', 'repl' => 'REPL', 'ui' => 'UI')
loader.setup
