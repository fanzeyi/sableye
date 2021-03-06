# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :sableye, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:sableye, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

config :sableye, ecto_repos: [Sableye.Model]

config :sableye, Sableye.Model,
  adapter: Ecto.Adapters.MySQL,
  database: "sableye",
  username: "sableye",
  password: "sableye",
  hostname: "localhost",
  port: "3306"

config :sableye,
  totp_key: "THIS IS A TOTP KEY",
  session_encryption_salt: "FSAUFPOAIDPAODLKKJWQOIEUC",
  session_signing_salt: "_)()_KOPDMOWIQE)(DKMLKN#OIPOFAP)",
  session_secret_key: "7DD9882BA80A4AB2A2EF336C10F4A5CC2143E3DD4EFA45E4AED3EA4D1BE88C5D"

config :recaptcha,
  public_key: "6LcY4yAUAAAAAK48eSi5OI1Jt-7Nb9FgCpzH58a8",
  secret: {:system, "RECAPTCHA_PRIVATE_KEY"}

import_config "#{Mix.env}.exs"
