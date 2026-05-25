# frozen_string_literal: true

require 'test_helper'

class RifferCode::Tools::WriteTest < Minitest::Test
  def setup
    @tool = RifferCode::Tools::Write.new
  end

  def test_writes_content_to_a_file
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        @tool.call(context: nil, path: 'out.txt', content: 'hello')

        assert_equal 'hello', File.read('out.txt')
      end
    end
  end

  def test_creates_missing_parent_directories
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        @tool.call(context: nil, path: 'nested/deep/out.txt', content: 'hi')

        assert_path_exists 'nested/deep/out.txt'
      end
    end
  end

  def test_returns_a_success_response
    Dir.mktmpdir do |dir|
      Dir.chdir(dir) do
        response = @tool.call(context: nil, path: 'out.txt', content: 'hello')

        assert_predicate response, :success?
      end
    end
  end
end
