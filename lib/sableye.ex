defmodule Sableye do
  use Application

  import Supervisor.Spec, warn: false

  require Logger

  def compile_template() do
    :erlydtl.compile_dir(Path.join(:code.priv_dir(:sableye), "templates") |> to_charlist,
                         :"Elixir.Sableye.Templates", [
      out_dir: "templates_out",
      libraries: [{:"Elixir.Filters", :"Elixir.Filters"}],
      default_libraries: [:"Elixir.Filters"]
    ])
  end

  def start(_type, _args) do
    compile_template()

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Sableye.Router, [], port: 3000),
      supervisor(Sableye.Model, [])
    ]

    Logger.info "Started listening to http://localhost:3000"

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
