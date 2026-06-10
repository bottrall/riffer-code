# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'json'

class RifferCode::SettingsTest < Minitest::Test
  def settings_file(dir, data)
    path = File.join(dir, 'settings.json')
    File.write(path, JSON.generate(data))
    path
  end

  def test_returns_default_model_when_file_is_absent
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'settings.json')

      assert_equal RifferCode::Settings::DEFAULT_MODEL, RifferCode::Settings.model(path: path)
    end
  end

  def test_returns_model_from_settings_file
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6' })

      assert_equal 'anthropic/claude-sonnet-4-6', RifferCode::Settings.model(path: path)
    end
  end

  def test_returns_nil_pricing_when_file_is_absent
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'settings.json')

      assert_nil RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)
    end
  end

  def test_returns_nil_pricing_for_unconfigured_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'models' => {} })

      assert_nil RifferCode::Settings.pricing_for('anthropic/claude-opus-4', path: path)
    end
  end

  def test_returns_input_pricing_for_configured_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3.0, 'output' => 15.0, 'cache_write' => 3.75, 'cache_read' => 0.3
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_in_delta(3.0, pricing[:input])
    end
  end

  def test_returns_output_pricing_for_configured_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3.0, 'output' => 15.0, 'cache_write' => 3.75, 'cache_read' => 0.3
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_in_delta(15.0, pricing[:output])
    end
  end

  def test_returns_cache_write_pricing_for_configured_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3.0, 'output' => 15.0, 'cache_write' => 3.75, 'cache_read' => 0.3
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_in_delta(3.75, pricing[:cache_write])
    end
  end

  def test_returns_cache_read_pricing_for_configured_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3.0, 'output' => 15.0, 'cache_write' => 3.75, 'cache_read' => 0.3
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_in_delta(0.3, pricing[:cache_read])
    end
  end

  def test_returns_default_model_for_malformed_json
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'settings.json')
      File.write(path, 'not json {{{')

      assert_equal RifferCode::Settings::DEFAULT_MODEL, RifferCode::Settings.model(path: path)
    end
  end

  def test_returns_nil_pricing_for_malformed_json
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'settings.json')
      File.write(path, 'not json {{{')

      assert_nil RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)
    end
  end

  def test_coerces_input_pricing_to_float
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3, 'output' => 15, 'cache_write' => 4, 'cache_read' => 0
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_kind_of Float, pricing[:input]
    end
  end

  def test_coerces_cache_read_pricing_to_float
    Dir.mktmpdir do |dir|
      path = settings_file(dir, {
                             'models' => {
                               'anthropic/claude-sonnet-4-6' => {
                                 'input' => 3, 'output' => 15, 'cache_write' => 4, 'cache_read' => 0
                               }
                             }
                           })

      pricing = RifferCode::Settings.pricing_for('anthropic/claude-sonnet-4-6', path: path)

      assert_kind_of Float, pricing[:cache_read]
    end
  end

  def test_provider_for_returns_anthropic_prefix
    assert_equal 'anthropic', RifferCode::Settings.provider_for('anthropic/claude-sonnet-4-6')
  end

  def test_provider_for_returns_openai_prefix
    assert_equal 'openai', RifferCode::Settings.provider_for('openai/gpt-5-mini')
  end

  def test_provider_for_returns_gemini_prefix
    assert_equal 'gemini', RifferCode::Settings.provider_for('gemini/gemini-2.5-flash')
  end

  def test_provider_for_returns_openrouter_prefix
    assert_equal 'openrouter', RifferCode::Settings.provider_for('openrouter/anthropic/claude-sonnet-4.6')
  end

  def test_provider_for_returns_nil_for_model_without_slash
    assert_nil RifferCode::Settings.provider_for('no-slash-model')
  end
end
