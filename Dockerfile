FROM hexpm/elixir:1.18.0-erlang-27.1.2-debian-bookworm-20240918-slim AS build

RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod

COPY mix.exs ./
COPY config ./config

RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod

COPY lib ./lib

RUN mix compile
RUN mix release

FROM debian:bookworm-slim AS app

RUN apt-get update && \
    apt-get install -y --no-install-recommends libstdc++6 libgcc-s1 libncurses6 openssl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV MIX_ENV=prod \
    PORT=8080

COPY --from=build /app/_build/prod/rel/ask_ouija ./

EXPOSE 8080

CMD ["bin/ask_ouija", "start"]
