# AskOuija

Multiplayer game where users guess what Reddit's answer will be in r/AskOuija.

## Overview
AskOuija is a Phoenix LiveView app that runs real-time multiplayer rounds. Players submit letters one at a time, watch the answer evolve live, and try to predict what the crowd will spell out based on AskOuija threads.

## Features
- Live multiplayer rounds with real-time updates via Phoenix LiveView.
- Server-rendered UI with minimal client-side JavaScript.
- Simple runtime configuration driven by environment variables.

## Tech Stack
- Elixir ~> 1.18
- Phoenix ~> 1.7
- Phoenix LiveView ~> 0.20

## Getting Started (Local Development)
1. Install dependencies:
   ```sh
   mix deps.get
   ```
2. Start the server:
   ```sh
   mix phx.server
   ```
3. Visit [`http://localhost:4000`](http://localhost:4000).

## Configuration
Runtime settings are configured in `config/runtime.exs` for production environments.

| Variable | Description | Default |
| --- | --- | --- |
| `PORT` | HTTP port for the web server | `4000` |
| `SECRET_KEY_BASE` | Secret key for session/cookie signing | `prodsecret` |

## Deploying
The app can be deployed anywhere that supports Elixir releases or a buildpack-based workflow.

### Option 1: Build a release
1. Fetch dependencies and compile:
   ```sh
   mix deps.get
   MIX_ENV=prod mix compile
   ```
2. Build the release:
   ```sh
   MIX_ENV=prod mix release
   ```
3. Set environment variables and start the release:
   ```sh
   export SECRET_KEY_BASE="<generated-secret>"
   export PORT=4000
   _build/prod/rel/ask_ouija/bin/ask_ouija start
   ```

### Option 2: Docker/Platform-as-a-Service
If your platform builds the release for you (e.g., Fly.io, Render, Gigalixir, or Heroku with buildpacks), ensure it sets:
- `SECRET_KEY_BASE`
- `PORT`

Then run the release start command exposed by the platform.

## Tests
```sh
mix test
```
