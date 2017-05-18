defmodule Sableye.Router do
  use Plug.Router
  use Plug.ErrorHandler

  import Sableye.Util

  require Logger

  plug Plug.Session,
    store: :cookie,
    key: "_session",
    encryption_salt: Application.get_env(:sableye, :session_encryption_salt),
    signing_salt: Application.get_env(:sableye, :session_signing_salt),
    key_length: 64
  plug Plug.Static, at: "/static", from: Path.join(:code.priv_dir(:sableye), "static")
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :put_secret_key_base
  plug :fetch_session
  plug :skip_csrf
  plug Plug.CSRFProtection
  plug :bind_user
  plug :tracking_user
  plug :match
  plug :dispatch

  def skip_csrf(conn, _) do
    conn = Plug.Conn.fetch_query_params(conn)

    case Map.get(conn.query_params, "csrf", nil) do
      "off" ->
        Plug.Conn.put_private(conn, :plug_skip_csrf_protection, true)
      _ ->
        conn
    end
  end

  def put_secret_key_base(conn, _) do
    put_in conn.secret_key_base, Application.get_env(:sableye, :session_secret_key)
  end

  def tracking_user(conn, _) do
    case conn.request_path do
      "/favicon.ico" -> conn
      _ ->
        conn
        |> assign(:last_visit, [
          path: Map.get(conn.cookies, "last_visited", ""),
          time: Map.get(conn.cookies, "last_visited_time", "")
        ])
        |> put_resp_cookie("last_visited", conn.request_path)
        |> put_resp_cookie("last_visited_time",
                           :os.system_time(:seconds) |> Integer.to_string)
    end
  end

  alias Sableye.Model

  def bind_user(conn, _) do
    with {:ok, user_id} <- error_tuple(get_session(conn, :user)),
      {:ok, user} <- error_tuple(Model.get(Model.User, user_id))
    do
      conn = assign(conn, :user, user)
      conn
    else
      {:error, _} -> conn
    end
  end

  get "/", do: Sableye.Home.home conn
  get "/privacy", do: Sableye.Home.privacy conn
  get "/tos", do: Sableye.Home.tos conn

  get "/register", do: Sableye.User._register :get, conn
  post "/register", do: Sableye.User._register :post, conn

  get "/login", do: Sableye.User.login :get, conn
  post "/login", do: Sableye.User.login :post, conn

  get "/logout", do: Sableye.User.logout :get, conn

  get "/totp", do: Sableye.User.totp :get, conn
  post "/totp", do: Sableye.User.totp :post, conn

  get "/totp_login", do: Sableye.User.totp_login :get, conn
  post "/totp_login", do: Sableye.User.totp_login :post, conn

  get "/_/create", do: Sableye.Post.create :get, conn
  post "/_/create", do: Sableye.Post.create :post, conn

  get "/post/:post_id", do: Sableye.Post.show :get, conn
  get "/post/:post_id/delete", do: Sableye.Post.delete :get, conn

  match _ do
    conn |> Sableye.View.render(:"404", [])
  end

  def handle_errors(conn, %{kind: kind, reason: reason, stack: stack}) do
    {:ok, resp} = Sableye.Templates.render(:"500", [message: Exception.format(kind, reason, stack)])

    send_resp(conn, conn.status, resp)
  end
end
