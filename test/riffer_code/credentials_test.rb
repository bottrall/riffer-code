# frozen_string_literal: true

require 'test_helper'

class RifferCode::CredentialsTest < Minitest::Test
  def test_round_trips_a_saved_key
    without_env do
      in_tmp_path do |path|
        RifferCode::Credentials.save_anthropic_api_key('sk-ant-stored', path: path)

        assert_equal 'sk-ant-stored', RifferCode::Credentials.anthropic_api_key(path: path)
      end
    end
  end

  def test_environment_variable_takes_precedence_over_stored_key
    in_tmp_path do |path|
      RifferCode::Credentials.save_anthropic_api_key('sk-ant-stored', path: path)
      ENV['ANTHROPIC_API_KEY'] = 'sk-ant-env'

      assert_equal 'sk-ant-env', RifferCode::Credentials.anthropic_api_key(path: path)
    ensure
      ENV.delete('ANTHROPIC_API_KEY')
    end
  end

  def test_returns_nil_when_no_key_is_available
    without_env do
      in_tmp_path do |path|
        assert_nil RifferCode::Credentials.anthropic_api_key(path: path)
      end
    end
  end

  def test_saved_file_is_owner_only_readable
    in_tmp_path do |path|
      RifferCode::Credentials.save_anthropic_api_key('sk-ant-stored', path: path)

      assert_equal 0o600, File.stat(path).mode & 0o777
    end
  end

  private

  def in_tmp_path
    Dir.mktmpdir do |dir|
      yield File.join(dir, 'auth.json')
    end
  end

  def without_env
    previous = ENV.delete('ANTHROPIC_API_KEY')
    yield
  ensure
    ENV['ANTHROPIC_API_KEY'] = previous if previous
  end
end
