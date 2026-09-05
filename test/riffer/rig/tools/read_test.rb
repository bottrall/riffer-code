# frozen_string_literal: true

require 'test_helper'

class Riffer::Rig::Tools::ReadTest < Minitest::Test
  def setup
    @tool = Riffer::Rig::Tools::Read.new
  end

  def test_reads_file_contents_with_line_numbers
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('greeting.txt', "hello\nworld")
        response = @tool.call(context: nil, path: 'greeting.txt')

        assert_includes response.content, "1\thello"
      end
    end
  end

  def test_offset_and_limit_select_a_slice
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('lines.txt', (1..10).map { |n| "line#{n}" }.join("\n"))
        response = @tool.call(context: nil, path: 'lines.txt', offset: 3, limit: 1)

        assert_equal "     3\tline3", response.content
      end
    end
  end

  def test_missing_file_returns_error
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        response = @tool.call(context: nil, path: 'nope.txt')

        assert_predicate response, :error?
      end
    end
  end

  def test_offset_below_one_returns_error
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('lines.txt', "a\nb\nc")
        response = @tool.call(context: nil, path: 'lines.txt', offset: 0)

        assert_predicate response, :error?
      end
    end
  end
end
