FROM elixir:1.19.5-alpine

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

# deps and _build are mounted as named Docker volumes in docker-compose.yml
# so dep compilation happens at container startup, not at image build time.
# This keeps the image small and avoids musl/glibc conflicts.

EXPOSE 4000

# mix deps.get is fast when deps are already cached in the named volume.
# mix phx.server starts the dev server with live-reload watchers for
# esbuild and Tailwind CSS.
CMD ["sh", "-c", "mix deps.get && mix phx.server"]
