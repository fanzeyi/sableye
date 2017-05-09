defmodule Sableye.User do
  import Plug.Conn

  alias Sableye.Model
  alias Plug.Session

  def format_errors(errors) do
    Enum.map(errors, fn({k, {msg, opts}}) ->
      Enum.reduce(opts ++ [label: Atom.to_string(k)], msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def redirect(conn, url) do
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> put_resp_header("content-type", "text/html")
    |> send_resp(conn.status || 302, body)
  end

  def render(conn, name, variables \\ []) do
    with {:ok, html} <- :templates.render(name, variables)
    do
      send_resp(conn, 200, html)
    else
      {:error, err} ->
        IO.puts inspect(err)
        raise inspect(err)
    end
  end

  def get_param(params, label) do
    case params[label] do
      x when is_nil(x) or x == "" ->
        {:error, "#{label} is required"}
      data -> {:ok, data}
    end
  end

  def _register(:get, conn) do
    conn |> render(:_register)
  end

  def _register(:post, conn) do
    changeset = Model.User.changeset(%Model.User{}, conn.params)

    case Model.insert(changeset) do
      {:ok, _} ->
        redirect(conn, "/login")
      {:error, changeset} ->
        conn |> render(:_register, [model: conn.params,
                                    errors: format_errors(changeset.errors)])
    end
  end

  def login(:get, conn) do
    conn |> render(:login)
  end

  def login(:post, conn) do
    with {:ok, username} <- get_param(conn.params, "username"),
         {:ok, password} <- get_param(conn.params, "password"),
         {:ok, user} <- Model.User.get_by_email_or_username(username),
         {:ok, _} <- Model.User.checkpw(user, password)
    do
      conn
      |> put_session(:user, user.id)
      |> redirect("/")
    else
      {:error, error} ->
        conn |> render(:login, [model: conn.params,
                                errors: [error]])
    end
  end
end
