# BusesMonitorElixir

# 1. Build the dev image
docker compose build

# 2. Start the container (fetches deps on first run ~60s, then starts server)
docker compose up

# 3. In a second terminal — create the SQLite database and run migrations
docker compose exec app mix ecto.create
docker compose exec app mix ecto.migrate

# 4. Open http://localhost:4000

To start your Phoenix server:

* Run `mix setup` to install and setup dependencies
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

* Official website: https://www.phoenixframework.org/
* Guides: https://hexdocs.pm/phoenix/overview.html
* Docs: https://hexdocs.pm/phoenix
* Forum: https://elixirforum.com/c/phoenix-forum
* Source: https://github.com/phoenixframework/phoenix
