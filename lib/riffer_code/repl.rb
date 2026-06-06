# frozen_string_literal: true

class RifferCode::REPL
  EXIT_COMMANDS = ['/exit', '/quit'].freeze
  SKILL_TOKEN = %r{/(?!(?:exit|quit)\b)([a-z0-9]+(?:-[a-z0-9]+)*)}

  def initialize(agent:, renderer:, input: $stdin, output: $stdout, theme: RifferCode::UI::Theme.for(output), animator: RifferCode::UI::Animator.new(io: output, theme:))
    @agent = agent
    @renderer = renderer
    @animator = animator
    @theme = theme
    @input = input
    @output = output
    @agent.session.on_message { |message| @renderer.render_tool_result(message) }
  end

  def run
    loop do
      @output.print("\n#{@theme.pink('›')} ")
      line = @input.gets
      break if line.nil?

      prompt = line.strip
      next if prompt.empty?
      break if EXIT_COMMANDS.include?(prompt)

      skill_names = prompt.scan(SKILL_TOKEN).flatten
      remaining = prompt.gsub(SKILL_TOKEN, '').strip

      skills_activated = skill_names.count { |name| activate_skill(name) }

      if remaining.empty?
        run_turn('') if skills_activated.positive?
      else
        run_turn(remaining)
      end
    end

    @output.puts("\n#{@theme.grey('see you on the next riff.')}")
  end

  private

  def run_turn(prompt)
    @animator.start_thinking
    @agent.stream(prompt).each do |event|
      @animator.stop_thinking
      @renderer.render(event)
    end
    @output.puts
  rescue StandardError => e
    @output.puts("\nError: #{e.message}")
  ensure
    @animator.stop_thinking
  end

  def activate_skill(name)
    skills = @agent.context.skills

    unless skills
      @output.puts(@theme.grey('No skills configured.'))
      return
    end

    skills.activate(name)
    @output.puts(@theme.magenta("✦ skill: #{name}"))
    true
  rescue Riffer::ArgumentError
    nil
  rescue StandardError => e
    @output.puts(@theme.red("Error activating skill: #{e.message}"))
  end
end
