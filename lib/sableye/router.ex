defmodule Sableye.Router do
  use Plug.Router
  use Plug.ErrorHandler

  plug Plug.Session,
    store: :cookie,
    key: "_session",
    encryption_salt: "encrypt  !! ",
    signing_salt: "sign  !!  ",
    key_length: 66
  plug Plug.Static, at: "/static", from: "./static"
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :put_secret_key_base
  plug :fetch_session
  plug :bind_user
  plug :match
  plug :dispatch

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base,
      "7DD9882BA80A4AB2A2EF336C10F4A5CC2143E3DD4EFA45E4AED3EA4D1BE88C5ACD"
  end

  alias Sableye.Model

  def bind_user(conn, _) do
    case get_session(conn, :user) do
      nil -> conn
      x -> case Model.get(Model.User, x) do
        nil ->
          conn
        user ->
          conn = assign(conn, :user, user)
          conn
      end
    end
  end

  get "/", do: Sableye.Home.home conn

  get "/register", do: Sableye.User._register :get, conn
  post "/register", do: Sableye.User._register :post, conn

  get "/login", do: Sableye.User.login :get, conn
  post "/login", do: Sableye.User.login :post, conn

  get "/logout", do: Sableye.User.logout :get, conn

  match _ do
    {:ok, resp} = :templates.render(:"404", [])
    send_resp(conn, 404, resp)
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    {:ok, resp} = :templates.render(:"500", [message: Exception.format(kind, reason, stack)])

    send_resp(conn, conn.status, resp)
  end
end
