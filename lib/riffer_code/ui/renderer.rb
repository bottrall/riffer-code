# frozen_string_literal: true

require 'json'

class RifferCode::UI::Renderer
  RESULT_PREVIEW_LIMIT = 200

  def initialize(io: $stdout, theme: RifferCode::UI::Theme.for(io))
    @io = io
    @theme = theme
  end

  def render(event)
    case event
    when Riffer::StreamEvents::TextDelta
      @io.print(event.content)
    when Riffer::StreamEvents::ToolCallDone
      @io.puts("\n#{@theme.cyan("⚙ #{event.name}(#{format_arguments(event.arguments)})")}")
    when Riffer::StreamEvents::Interrupt
      @io.puts(@theme.dim("[interrupted: #{event.reason}]"))
    end
  end

  def render_tool_result(message)
    return unless message.is_a?(Riffer::Messages::Tool)

    line = "↳ #{preview(message.content)}"
    @io.puts(message.error? ? @theme.red(line) : @theme.dim(line))
  end

  private

  def format_arguments(arguments)
    parsed = JSON.parse(arguments)
    parsed.map { |key, value| "#{key}: #{value.inspect}" }.join(', ')
  rescue JSON::ParserError
    arguments
  end

  def preview(content)
    first_line = content.to_s.lines.first.to_s.chomp
    return first_line if first_line.length <= RESULT_PREVIEW_LIMIT

    "#{first_line[0, RESULT_PREVIEW_LIMIT]}…"
  end
end
