defmodule Sableye do
  use Application

  require Logger

  def start(_type, _args) do
    :erlydtl.compile_dir('templates', :templates, [out_dir: "templates_out"])

    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Sableye.Router, [], port: 3000)
    ]

    Logger.info "Started listening to http://localhost:3000"

    Supervisor.start_link(children, strategy: :one_for_one)
  end

end
