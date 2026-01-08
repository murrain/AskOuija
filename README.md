# Speed Trivia

Real-time multiplayer trivia game with fast, timed rounds and hidden answers.

## Overview
Speed Trivia is a Phoenix LiveView app that runs real-time multiplayer rounds. Players submit a single answer per question, then see results and scores once the timer expires or everyone answers.

## Features
- Live multiplayer rounds with real-time updates via Phoenix LiveView.
- Server-rendered UI with minimal client-side JavaScript.
- Simple runtime configuration driven by environment variables.
- Optional Reddit scraping workflow to build a prompt dataset from AskOuija posts.

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

### Reddit prompt scraping
The scraper can run independently from the game server to build a JSON prompt dataset. Use the mix
task to run it on demand:

```sh
mix ask_ouija.scrape_reddit
```

To load scraped prompts in the game, set the provider in config to
`AskOuija.Prompts.FileProvider` and ensure the output path is available.

Scraper-related environment variables:

| Variable | Description | Default |
| --- | --- | --- |
| `REDDIT_SCRAPE_ENABLED` | Enable the scheduled scraper when starting the app | `false` |
| `REDDIT_SCRAPE_INTERVAL_MS` | Interval between scheduled runs (milliseconds) | `86400000` |
| `REDDIT_SUBREDDIT` | Subreddit to scrape | `AskOuija` |
| `REDDIT_SCRAPE_LIMIT` | Max posts per scrape | `100` |
| `REDDIT_USER_AGENT` | HTTP user agent for Reddit requests | `ask_ouija_scraper/0.1` |
| `REDDIT_OUTPUT_PATH` | JSON output file path for scraped prompts | `priv/data/reddit_prompts.json` |

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
