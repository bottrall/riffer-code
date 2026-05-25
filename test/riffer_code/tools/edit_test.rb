# frozen_string_literal: true

require 'test_helper'

class RifferCode::Tools::EditTest < Minitest::Test
  def setup
    @tool = RifferCode::Tools::Edit.new
  end

  def test_replaces_a_unique_string
    with_file('foo bar baz') do
      @tool.call(context: nil, path: 'f.txt', old_string: 'bar', new_string: 'QUX')

      assert_equal 'foo QUX baz', File.read('f.txt')
    end
  end

  def test_missing_old_string_returns_error
    with_file('foo bar') do
      response = @tool.call(context: nil, path: 'f.txt', old_string: 'nope', new_string: 'x')

      assert_predicate response, :error?
    end
  end

  def test_non_unique_match_without_replace_all_returns_error
    with_file('x x x') do
      response = @tool.call(context: nil, path: 'f.txt', old_string: 'x', new_string: 'y')

      assert_predicate response, :error?
    end
  end

  def test_replace_all_replaces_every_occurrence
    with_file('x x x') do
      @tool.call(context: nil, path: 'f.txt', old_string: 'x', new_string: 'y', replace_all: true)

      assert_equal 'y y y', File.read('f.txt')
    end
  end

  def test_backslash_sequences_in_replacement_are_inserted_literally
    with_file('foo bar baz') do
      @tool.call(context: nil, path: 'f.txt', old_string: 'bar', new_string: '\0\1')

      assert_equal 'foo \0\1 baz', File.read('f.txt')
    end
  end

  private

  def with_file(content)
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        File.write('f.txt', content)
        yield
      end
    end
  end
end
