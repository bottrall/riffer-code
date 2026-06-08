# frozen_string_literal: true

require 'test_helper'

class RifferCode::TokenTallyTest < Minitest::Test
  SONNET_PRICING = { input: 3.0, output: 15.0, cache_write: 3.75, cache_read: 0.3 }.freeze

  def usage(input:, output:, cache_write: nil, cache_read: nil)
    Riffer::Providers::TokenUsage.new(
      input_tokens: input,
      output_tokens: output,
      cache_creation_tokens: cache_write,
      cache_read_tokens: cache_read
    )
  end

  def test_starts_with_zero_tokens
    tally = RifferCode::TokenTally.new

    assert_equal 0, tally.total_tokens
  end

  def test_any_returns_false_when_empty
    tally = RifferCode::TokenTally.new

    refute_predicate tally, :any?
  end

  def test_accumulates_input_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 100, output: 50))
    tally.add(usage(input: 200, output: 75))

    assert_equal 300, tally.input_tokens
  end

  def test_accumulates_output_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 100, output: 50))
    tally.add(usage(input: 200, output: 75))

    assert_equal 125, tally.output_tokens
  end

  def test_accumulates_cache_write_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 0, output: 0, cache_write: 500, cache_read: 200))
    tally.add(usage(input: 0, output: 0, cache_write: 100, cache_read: 800))

    assert_equal 600, tally.cache_write_tokens
  end

  def test_accumulates_cache_read_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 0, output: 0, cache_write: 500, cache_read: 200))
    tally.add(usage(input: 0, output: 0, cache_write: 100, cache_read: 800))

    assert_equal 1000, tally.cache_read_tokens
  end

  def test_handles_nil_cache_tokens_gracefully
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 10, output: 5))

    assert_equal 15, tally.total_tokens
  end

  def test_total_tokens_sums_all_categories
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 100, output: 50, cache_write: 400, cache_read: 200))

    assert_equal 750, tally.total_tokens
  end

  def test_any_returns_true_after_adding_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    tally.add(usage(input: 1, output: 0))

    assert_predicate tally, :any?
  end

  def test_estimated_cost_uses_pricing
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    # 1M input @ $3.0/M + 1M output @ $15.0/M = $18.0
    tally.add(usage(input: 1_000_000, output: 1_000_000))

    assert_in_delta 18.0, tally.estimated_cost, 0.0001
  end

  def test_estimated_cost_includes_cache_tokens
    tally = RifferCode::TokenTally.new(pricing: SONNET_PRICING)
    # 1M cache_write @ $3.75/M + 1M cache_read @ $0.30/M = $4.05
    tally.add(usage(input: 0, output: 0, cache_write: 1_000_000, cache_read: 1_000_000))

    assert_in_delta 4.05, tally.estimated_cost, 0.0001
  end

  def test_estimated_cost_returns_nil_when_no_pricing_provided
    tally = RifferCode::TokenTally.new
    tally.add(usage(input: 100, output: 50))

    assert_nil tally.estimated_cost
  end
end
