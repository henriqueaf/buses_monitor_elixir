# ============================================================
# Stage 1 – build (shared base for dev and prod builder)
# ============================================================
FROM elixir:1.19.5-alpine AS build

# Install system dependencies required for:
# - build-base: GCC/Make for compiling native extensions (exqlite NIF)
# - git: fetching Mix dependencies from git sources
# - sqlite-dev: SQLite headers needed to compile exqlite NIF on Alpine/musl
# - inotify-tools: file-system watching for Phoenix live reload on Linux
# - nodejs + npm: asset building (esbuild / Tailwind CSS)
RUN apk add --no-cache \
    build-base \
    git \
    sqlite-dev \
    inotify-tools \
    nodejs \
    npm

# Install Hex package manager and Rebar build tool globally into the image.
# They live in /root/.mix which is NOT overridden by any volume mount.
RUN mix local.hex --force && \
    mix local.rebar --force

WORKDIR /app

EXPOSE 4000

# ============================================================
# Stage 2 – dev
# ============================================================
FROM build AS dev

# Source code and config are bind-mounted by docker-compose at runtime.
# deps and _build are named volumes managed by docker-compose, so
# dep compilation happens at container startup to leverage the cache.
CMD ["sh", "-c", "mix deps.get && mix phx.server"]

# ============================================================
# Stage 3 – prod_builder (compile release artefacts)
# ============================================================
FROM build AS prod_builder

ENV MIX_ENV=prod

# Fetch ALL dependencies (not just --only prod) so that dev-only
# asset build tools (esbuild, tailwind) are available for
# `mix assets.deploy` before they are excluded from the release.
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy config before compiling deps so compile-time config is applied.
COPY config config
RUN mix deps.compile

COPY priv priv
COPY lib lib
COPY assets assets

# Compile the app so that the phoenix_live_view compiler generates the
# virtual phoenix-colocated package (required by esbuild in assets.deploy).
RUN mix compile

# Compile JS/CSS assets and generate cache-busted digests in priv/static.
RUN mix assets.deploy

# Build the self-contained OTP release.
# RUN SECRET_KEY_BASE=$(mix phx.gen.secret) mix do phx.digest, release
RUN mix release

# ============================================================
# Stage 4 – prod (minimal runtime image)
# ============================================================
FROM alpine:3.23 AS prod

# Runtime shared libraries required by the OTP release:
#   libstdc++    – Erlang runtime
#   openssl      – crypto / TLS support
#   ncurses-libs – terminal handling used by OTP shell
#   sqlite-libs  – SQLite shared library for the exqlite NIF
RUN apk add --no-cache \
    libstdc++ \
    openssl \
    ncurses-libs \
    sqlite-libs

WORKDIR /app

# Copy only the self-contained release; no Elixir/Erlang toolchain needed.
COPY --from=prod_builder /app/_build/prod/rel/buses_monitor_elixir ./

# Tell Phoenix to start the HTTP server on boot.
ENV PHX_SERVER=true

EXPOSE 4000

CMD ["bin/buses_monitor_elixir", "start"]
