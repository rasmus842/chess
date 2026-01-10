# Repository Guidelines

## Project Structure & Module Organization
- `lib/` holds application code. Domain logic lives under `lib/chess/`, web layer under `lib/chess_web/` (controllers, LiveView, components, router).
- `test/` contains ExUnit tests, with shared helpers in `test/support/`.
- `assets/` contains JS/CSS sources and build config; built assets are emitted to `priv/static/`.
- `config/` contains environment-specific configuration (dev/test/prod, runtime).
- `priv/` holds static assets, gettext files, and database seeds in `priv/repo/seeds.exs`.

## Build, Test, and Development Commands
- `mix setup` installs deps, sets up the database, and builds assets.
- `mix phx.server` runs the Phoenix server on `localhost:4000`.
- `iex -S mix phx.server` runs the server with an interactive Elixir shell.
- `mix test` runs the test suite (creates/migrates the test DB via alias).
- `mix assets.build` builds JS/CSS for local dev; `mix assets.deploy` builds and digests for production.

## Coding Style & Naming Conventions
- Format with `mix format` (see `.formatter.exs` for project inputs).
- Elixir: 2-space indentation; modules in `CamelCase`, functions/variables in `snake_case`.
- Files: `snake_case.ex` or `snake_case.exs`; HEEx templates are `.heex`.

## Testing Guidelines
- Test framework: ExUnit.
- Test files end with `_test.exs` and mirror the module namespace (e.g., `test/chess/game/king_move_test.exs`).
- Use helpers in `test/support/` for shared setup.
- No explicit coverage threshold is defined; keep new behavior covered.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and capitalized (e.g., "Fix castling rule").
- PRs should include a concise summary, testing notes, and screenshots for UI changes.
- Link related issues when available.

## Configuration & Data
- Database configuration is in `config/*.exs`; the app uses Ecto/Postgres.
- Seed data: `priv/repo/seeds.exs`.
