defmodule Sableye.View do
  import Plug.Conn
  require Logger

  def render(conn, name, variables \\ []) do
    variables = variables ++ [user: conn.assigns[:user]]
    Logger.debug inspect(variables)

    with {:ok, html} <- :templates.render(name, variables)
    do
      send_resp(conn, 200, html)
    else
      {:error, err} ->
        IO.puts inspect(err)
        raise inspect(err)
    end
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
    case params[label] do
      x when is_nil(x) or x == "" ->
        {:error, "#{label} is required"}
      data -> {:ok, data}
    end
  end

  def ok_non_empty(things) do
    case things do
      nil -> {:error, ""}
      t -> {:ok, t}
    end
  end
end
