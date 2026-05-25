# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::UI::AnimatorTest < Minitest::Test
  def setup
    @io = StringIO.new
    @animator = RifferCode::UI::Animator.new(io: @io, theme: RifferCode::UI::Theme.new(enabled: false))
  end

  def test_reveal_prints_the_final_frame_when_not_a_tty
    @animator.reveal([['frame one'], ['final']])

    assert_equal "final\n", @io.string
  end

  def test_stop_thinking_without_start_does_not_raise
    @animator.stop_thinking

    assert_equal '', @io.string
  end

  def test_start_thinking_is_a_no_op_when_not_a_tty
    @animator.start_thinking

    assert_equal '', @io.string
  end
end
