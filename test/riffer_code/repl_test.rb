# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::REPLTest < Minitest::Test
  def test_run_exits_on_empty_input_and_prints_the_sign_off
    output = StringIO.new
    theme = RifferCode::UI::Theme.new(enabled: false)
    renderer = RifferCode::UI::Renderer.new(io: output, theme: theme)
    repl = RifferCode::REPL.new(agent: RifferCode::CodingAgent.new, renderer: renderer, input: StringIO.new(''), output: output, theme: theme)

    repl.run

    assert_includes output.string, 'next riff'
  end
end
