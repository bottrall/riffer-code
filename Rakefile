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

desc 'Generate RBS signatures from inline annotations'
task :'sig:generate' do
  sh 'rbs-inline --opt-out --output=sig/generated lib'
end

desc 'Fail if the committed RBS is out of date with the source'
task :'sig:check' do
  Dir.mktmpdir do |dir|
    sh "rbs-inline --opt-out --output=#{dir} lib > /dev/null"
    sh "diff -r sig/generated #{dir}" do |ok, _res|
      abort 'sig/generated is out of date — run `bin/rake sig:generate`' unless ok
    end
  end
end

desc 'Type-check with Steep'
task :steep do
  sh 'steep check'
end

task default: %i[test rubocop sig:check steep]
