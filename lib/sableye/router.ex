defmodule Sableye.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  get "/", do: Sableye.Home.home conn

  match _ do
    {:ok, resp} = :templates.render(:"404", [])
    send_resp(conn, 404, resp)
  end
end
