import Config
config :five_apps, token_signing_secret: "2WXF/6DtJHze0bCH5xsjWt7iWjHzcZON"
config :bcrypt_elixir, log_rounds: 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :five_apps, FiveApps.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "five_apps_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :five_apps, FiveAppsWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "I95AJX4AK8O2gQnsm9UNCopoIEpCV25M+w26RKtfQ2APK1xA4do9ndl1fR7T6uH7",
  server: false

# In test we don't send emails
config :five_apps, FiveApps.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
