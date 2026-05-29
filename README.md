# riffer-code

A dead-simple terminal coding agent built on [riffer](https://github.com/janeapp/riffer).

`riffer-code` is an interactive terminal coding agent with read, write, edit, and bash tools — point it at your project and chat with it from the command line.

## Requirements

- Ruby >= 4.0

## Installation

Install the gem:

```bash
gem install riffer-code
```

This provides a `riffer-code` executable.

## Usage

Run the agent from any project directory:

```bash
riffer-code
```

### Authentication

`riffer-code` talks to Anthropic. Provide your API key in either of two ways:

- Set the `ANTHROPIC_API_KEY` environment variable, or
- Run `riffer-code` and paste your key when prompted on first launch. It is saved to `~/.riffer-code/auth.json` (file permissions `600`) for subsequent runs.

Create a key at https://console.anthropic.com/settings/keys.

### Configuration

- `RIFFER_CODE_MODEL` — override the default model.
- `AGENTS.md` — if present, an `AGENTS.md` in the current working directory and/or a global `~/.riffer-code/AGENTS.md` is loaded as additional context.

## Development

After checking out the repo, install dependencies:

```bash
bin/install
```

Run the test suite:

```bash
bundle exec rake test
```

Check code style and types:

```bash
bundle exec rubocop
bundle exec steep check
```

## Contributing

1. Fork the repository and create your branch: `git checkout -b feature/foo`
2. Run the tests and linters locally.
3. Submit a pull request with a clear description of the change.

Please follow the [Code of Conduct](CODE_OF_CONDUCT.md).

## License

Licensed under the MIT License. See [`LICENSE.txt`](LICENSE.txt) for details.

## Maintainer

- Jake Bottrall - https://github.com/bottrall
