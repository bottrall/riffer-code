# frozen_string_literal: true

require 'test_helper'

class Riffer::Rig::CredentialsTest < Minitest::Test
  def test_round_trips_a_saved_key
    without_env do
      in_tmp_path do |path|
        Riffer::Rig::Credentials.save_api_key('anthropic', 'sk-ant-stored', path: path)

        assert_equal 'sk-ant-stored', Riffer::Rig::Credentials.api_key_for('anthropic', path: path)
      end
    end
  end

  def test_environment_variable_takes_precedence_over_stored_key
    in_tmp_path do |path|
      Riffer::Rig::Credentials.save_api_key('anthropic', 'sk-ant-stored', path: path)
      ENV['ANTHROPIC_API_KEY'] = 'sk-ant-env'

      assert_equal 'sk-ant-env', Riffer::Rig::Credentials.api_key_for('anthropic', path: path)
    ensure
      ENV.delete('ANTHROPIC_API_KEY')
    end
  end

  def test_returns_nil_when_no_key_is_available
    without_env do
      in_tmp_path do |path|
        assert_nil Riffer::Rig::Credentials.api_key_for('anthropic', path: path)
      end
    end
  end

  def test_saved_file_is_owner_only_readable
    in_tmp_path do |path|
      Riffer::Rig::Credentials.save_api_key('anthropic', 'sk-ant-stored', path: path)

      assert_equal 0o600, File.stat(path).mode & 0o777
    end
  end

  def test_stores_and_retrieves_openai_key_from_env
    in_tmp_path do |path|
      ENV['OPENAI_API_KEY'] = 'sk-openai-env'

      assert_equal 'sk-openai-env', Riffer::Rig::Credentials.api_key_for('openai', path: path)
    ensure
      ENV.delete('OPENAI_API_KEY')
    end
  end

  def test_stores_and_retrieves_openai_key_from_file
    in_tmp_path do |path|
      ENV.delete('OPENAI_API_KEY')
      Riffer::Rig::Credentials.save_api_key('openai', 'sk-openai-stored', path: path)

      assert_equal 'sk-openai-stored', Riffer::Rig::Credentials.api_key_for('openai', path: path)
    end
  end

  def test_stores_and_retrieves_gemini_key_from_file
    in_tmp_path do |path|
      ENV.delete('GEMINI_API_KEY')
      Riffer::Rig::Credentials.save_api_key('gemini', 'gemini-stored', path: path)

      assert_equal 'gemini-stored', Riffer::Rig::Credentials.api_key_for('gemini', path: path)
    end
  end

  def test_stores_and_retrieves_openrouter_key_from_file
    in_tmp_path do |path|
      ENV.delete('OPENROUTER_API_KEY')
      Riffer::Rig::Credentials.save_api_key('openrouter', 'sk-or-stored', path: path)

      assert_equal 'sk-or-stored', Riffer::Rig::Credentials.api_key_for('openrouter', path: path)
    end
  end

  def test_anthropic_key_survives_after_adding_openai_key
    in_tmp_path do |path|
      ENV.delete('ANTHROPIC_API_KEY')
      ENV.delete('OPENAI_API_KEY')

      Riffer::Rig::Credentials.save_api_key('anthropic', 'sk-ant', path: path)
      Riffer::Rig::Credentials.save_api_key('openai', 'sk-oai', path: path)

      assert_equal 'sk-ant', Riffer::Rig::Credentials.api_key_for('anthropic', path: path)
    end
  end

  def test_openai_key_survives_after_adding_anthropic_key
    in_tmp_path do |path|
      ENV.delete('ANTHROPIC_API_KEY')
      ENV.delete('OPENAI_API_KEY')

      Riffer::Rig::Credentials.save_api_key('anthropic', 'sk-ant', path: path)
      Riffer::Rig::Credentials.save_api_key('openai', 'sk-oai', path: path)

      assert_equal 'sk-oai', Riffer::Rig::Credentials.api_key_for('openai', path: path)
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
