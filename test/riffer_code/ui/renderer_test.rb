# frozen_string_literal: true

require 'test_helper'
require 'stringio'

class RifferCode::UI::RendererTest < Minitest::Test
  def setup
    @io = StringIO.new
    @renderer = RifferCode::UI::Renderer.new(io: @io, theme: RifferCode::UI::Theme.new(enabled: false))
  end

  def test_writes_text_delta_content_to_the_io
    @renderer.render(Riffer::StreamEvents::TextDelta.new('hello'))

    assert_equal 'hello', @io.string
  end

  def test_renders_tool_results_without_ansi_when_theme_disabled
    message = Riffer::Messages::Tool.new('done', tool_call_id: 'c1', name: 'write')
    @renderer.render_tool_result(message)

    refute_includes @io.string, "\e["
  end
end
