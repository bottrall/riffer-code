# frozen_string_literal: true

require 'io/console'

module RifferCode::CLI
  extend self

  def start(output: $stdout, input: $stdin)
    theme = RifferCode::UI::Theme.for(output)

    api_key = RifferCode::Credentials.anthropic_api_key || onboard(theme, output:, input:)
    return 1 if api_key.nil?

    Riffer.configure { |config| config.anthropic.api_key = api_key }

    agent = RifferCode::CodingAgent.new
    animator = RifferCode::UI::Animator.new(io: output, theme:)

    reveal_banner(theme, animator)

    renderer = RifferCode::UI::Renderer.new(io: output, theme:)
    RifferCode::REPL.new(agent:, renderer:, animator:, theme:, input:, output:).run
    0
  end

  private

  def onboard(theme, output:, input:)
    output.puts(theme.cyan('♪ welcome to riffer-code ♪'))
    output.puts(theme.grey('No Anthropic API key found. Create one at https://console.anthropic.com/settings/keys'))
    output.print("#{theme.pink('›')} Paste your Anthropic API key #{theme.grey('(hidden)')}: ")

    key = read_secret(input).to_s.strip
    output.puts

    if key.empty?
      output.puts(theme.grey('No key entered. Set ANTHROPIC_API_KEY or re-run riffer-code to try again.'))
      return nil
    end

    RifferCode::Credentials.save_anthropic_api_key(key)
    output.puts(theme.grey("Saved to #{RifferCode::Credentials::PATH} (permissions 600)."))
    key
  end

  def read_secret(input)
    return input.noecho(&:gets) if input.respond_to?(:noecho) && input.tty?

    input.gets
  end

  def reveal_banner(theme, animator)
    loaded = [RifferCode::CodingAgent::GLOBAL_AGENTS_FILE, File.join(Dir.pwd, 'AGENTS.md')].select { |path| File.file?(path) }
    model = ENV.fetch('RIFFER_CODE_MODEL', RifferCode::CodingAgent::DEFAULT_MODEL)
    context = loaded.empty? ? 'none' : loaded.join(', ')

    glints = RifferCode::UI::Riffy::GLINT_COLS + [nil]
    frames = glints.map do |glint_col|
      RifferCode::UI::Banner.lines(theme, model: model, cwd: Dir.pwd, context: context, skills: count_skills, version: RifferCode::VERSION, glint_col: glint_col)
    end
    animator.reveal(frames)
  end

  def count_skills
    dirs = [
      RifferCode::CodingAgent::GLOBAL_SKILLS_DIR,
      RifferCode::CodingAgent::PROJECT_SKILLS_DIR.call
    ]
    backend = Riffer::Skills::FilesystemBackend.new(*dirs)
    count = backend.list_skills.length
    count.zero? ? 'none' : count.to_s
  rescue StandardError
    'none'
  end
end
