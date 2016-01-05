# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :stataz_api, StatazApi.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "sPZjCpp+T8Plu7ncOLa13KgUH+0DYT470VKnqVUswawiht/9c4ehrtVdht02RfVz",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: StatazApi.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure your database
config :stataz_api, StatazApi.Repo,
  adapter: Ecto.Adapters.Postgres,
  hostname: "localhost",
  pool_size: 10

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

if File.exists? "config/#{Mix.env}.secret.exs" do
  import_config "#{Mix.env}.secret.exs"
end

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
