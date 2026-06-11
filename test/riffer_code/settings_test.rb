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

  # model_options — no reasoning configured

  def test_model_options_includes_cache_control_for_anthropic_model
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6' })

      assert_equal({ type: :ephemeral }, RifferCode::Settings.model_options(path: path)[:cache_control])
    end
  end

  def test_model_options_returns_empty_hash_for_openai_model_without_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3' })

      assert_equal({}, RifferCode::Settings.model_options(path: path))
    end
  end

  def test_model_options_returns_empty_hash_when_file_is_absent
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'settings.json')

      opts = RifferCode::Settings.model_options(path: path)

      # Default model is Anthropic — expect cache_control only, no reasoning
      assert_equal({ cache_control: { type: :ephemeral } }, opts)
    end
  end

  # model_options — Anthropic reasoning levels

  def test_model_options_sets_anthropic_effort_for_low_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'low' })

      assert_equal 'low', RifferCode::Settings.model_options(path: path)[:output_config][:effort]
    end
  end

  def test_model_options_sets_anthropic_effort_for_medium_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'medium' })

      assert_equal 'medium', RifferCode::Settings.model_options(path: path)[:output_config][:effort]
    end
  end

  def test_model_options_sets_anthropic_effort_for_high_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'high' })

      assert_equal 'high', RifferCode::Settings.model_options(path: path)[:output_config][:effort]
    end
  end

  def test_model_options_retains_cache_control_when_anthropic_reasoning_is_set
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'low' })

      opts = RifferCode::Settings.model_options(path: path)

      assert_equal({ type: :ephemeral }, opts[:cache_control])
    end
  end

  # model_options — OpenAI reasoning levels

  def test_model_options_sets_reasoning_effort_for_openai_low
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3', 'reasoning' => 'low' })

      assert_equal 'low', RifferCode::Settings.model_options(path: path)[:reasoning]
    end
  end

  def test_model_options_sets_reasoning_effort_for_openai_high
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3', 'reasoning' => 'high' })

      assert_equal 'high', RifferCode::Settings.model_options(path: path)[:reasoning]
    end
  end

  # model_options — OpenRouter reasoning levels

  def test_model_options_sets_reasoning_effort_for_openrouter_medium
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openrouter/anthropic/claude-sonnet-4.6', 'reasoning' => 'medium' })

      assert_equal 'medium', RifferCode::Settings.model_options(path: path)[:reasoning]
    end
  end

  def test_model_options_sets_anthropic_effort_for_xhigh_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'xhigh' })

      assert_equal 'xhigh', RifferCode::Settings.model_options(path: path)[:output_config][:effort]
    end
  end

  def test_model_options_sets_anthropic_effort_for_max_reasoning
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'anthropic/claude-sonnet-4-6', 'reasoning' => 'max' })

      assert_equal 'max', RifferCode::Settings.model_options(path: path)[:output_config][:effort]
    end
  end

  def test_model_options_sets_reasoning_effort_for_openai_xhigh
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3', 'reasoning' => 'xhigh' })

      assert_equal 'xhigh', RifferCode::Settings.model_options(path: path)[:reasoning]
    end
  end

  def test_model_options_sets_reasoning_effort_for_openrouter_xhigh
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openrouter/anthropic/claude-sonnet-4.6', 'reasoning' => 'xhigh' })

      assert_equal 'xhigh', RifferCode::Settings.model_options(path: path)[:reasoning]
    end
  end

  # model_options — invalid / unknown reasoning values

  def test_model_options_ignores_unrecognised_reasoning_value
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3', 'reasoning' => 'turbo' })

      refute RifferCode::Settings.model_options(path: path).key?(:reasoning)
    end
  end

  def test_model_options_ignores_max_reasoning_for_openai
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openai/o3', 'reasoning' => 'max' })

      refute RifferCode::Settings.model_options(path: path).key?(:reasoning)
    end
  end

  def test_model_options_ignores_max_reasoning_for_openrouter
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'openrouter/anthropic/claude-sonnet-4.6', 'reasoning' => 'max' })

      refute RifferCode::Settings.model_options(path: path).key?(:reasoning)
    end
  end

  def test_model_options_ignores_reasoning_key_for_provider_without_support
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'gemini/gemini-2.5-flash', 'reasoning' => 'high' })

      refute RifferCode::Settings.model_options(path: path).key?(:reasoning)
    end
  end

  def test_model_options_ignores_output_config_for_provider_without_support
    Dir.mktmpdir do |dir|
      path = settings_file(dir, { 'model' => 'gemini/gemini-2.5-flash', 'reasoning' => 'high' })

      refute RifferCode::Settings.model_options(path: path).key?(:output_config)
    end
  end
end
