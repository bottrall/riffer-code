# frozen_string_literal: true

require 'rake/testtask'
require 'rubocop/rake_task'
require 'tmpdir'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test' << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
  t.warning = false
end

RuboCop::RakeTask.new

namespace :rbs do
  desc 'Generate RBS signatures from inline annotations'
  task :generate do
    sh 'rbs-inline --opt-out --output=sig/generated lib'
  end

  desc 'Watch lib/ for changes and regenerate RBS files'
  task :watch do
    require 'guard'
    require 'guard/commander'

    Guard.start(no_interactions: true)
  end
end

namespace :steep do
  desc 'Type-check with Steep'
  task :check do
    sh 'steep check'
  end
end

task default: %i[test rubocop steep:check]
