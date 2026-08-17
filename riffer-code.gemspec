# frozen_string_literal: true

require_relative 'lib/riffer_code/version'

Gem::Specification.new do |spec|
  spec.name = 'riffer-code'
  spec.version = RifferCode::VERSION
  spec.authors = ['Jake Bottrall']
  spec.email = ['jakebottrall@gmail.com']

  spec.summary = 'A dead-simple terminal coding agent built on riffer.'
  spec.description = 'An interactive terminal coding agent (read/write/edit/bash) built on the riffer agentic framework.'
  spec.homepage = 'https://github.com/bottrall/riffer-code'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 4.0'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'exe/*', 'README.md']
  spec.bindir = 'exe'
  spec.executables = ['riffer-code']
  spec.require_paths = ['lib']

  spec.add_dependency 'anthropic', '~> 1.42'
  spec.add_dependency 'base64', '~> 0.2'
  spec.add_dependency 'riffer', '>= 0.32.1', '< 0.41.0'
  spec.add_dependency 'zeitwerk', '~> 2.6'
end
