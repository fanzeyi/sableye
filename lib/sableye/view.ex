defmodule Sableye.View do
  import Plug.Conn
  import Sableye.Util

  require Logger

  def render(conn, name, variables \\ []) do
    {conn, flash} = conn |> get_flash()

    variables = variables ++ [user: conn.assigns[:user],
                              last_visit: Map.get(conn.assigns, :last_visit, []),
                              flash: flash]

    with {:ok, html} <- Sableye.Templates.render(name, variables)
    do
      send_resp(conn, 200, html)
    else
      {:error, err} ->
        raise inspect(err)
    end
  end

  def get_flash(conn) do
    message = get_session(conn, :flash_message)
    type = get_session(conn, :flash_type)

    case message do
      nil -> {conn, nil}
      _ -> {conn |> delete_session(:flash_message) |> delete_session(:flash_type),
      [message: message, type: type]}
    end
  end

  def set_flash(conn, message, type \\ :info) do
    conn
    |> put_session(:flash_message, message)
    |> put_session(:flash_type, type)
  end

  def redirect(conn, url) do
    html = Plug.HTML.html_escape(url)
    body = "<html><body>You are being <a href=\"#{html}\">redirected</a>.</body></html>"

    conn
    |> put_resp_header("location", url)
    |> put_resp_header("content-type", "text/html")
    |> send_resp(conn.status || 302, body)
  end

  def format_errors(errors) do
    Enum.map(errors, fn({k, {msg, opts}}) ->
      Enum.reduce(opts ++ [label: Atom.to_string(k)], msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def get_param(params, label) do
    error_tuple(params[label], "#{label} is required!")
  end

  def get_session?(conn, name) do
    error_tuple(get_session(conn, name))
  end
end
