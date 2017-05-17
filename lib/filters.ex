defmodule Filters do
  @behaviour :erlydtl_library

  alias Earmark.Options

  require Logger

  def version() do
    1
  end

  def ndt_to_erl(value) do
    value |> NaiveDateTime.to_erl
  end

  def csrf_token(_value) do
    ['<input type="hidden" name="_csrf_token" value="',
    Plug.CSRFProtection.get_csrf_token(),
    '">']
  end

  def string(value) do
    to_string(value)
  end

  def mystriptags(value) do
    Regex.replace(~r/(<[^>]+>)/, value, "")
  end

  def myescape(value) do
    value
    |> (&Regex.replace(~r/&/, &1, "&amp;")).()
    |> (&Regex.replace(~r/</, &1, "&lt;")).()
    |> (&Regex.replace(~r/>/, &1, "&gt;")).()
    |> (&Regex.replace(~r/'/, &1, "&#39;")).()
    |> (&Regex.replace(~r/"/, &1, "&quot;")).()
  end

  def md(value) do
    Earmark.as_html!(value, %Options{smartypants: false})
  end

  def xss(value) do
    value
    |> (&Regex.replace(~r/&quot;/, &1, "\"")).()
    |> (&Regex.replace(~r/&#39;/, &1, "'")).()
    |> (&Regex.replace(~r/&lt;/, &1, "<")).()
    |> (&Regex.replace(~r/&gt;/, &1, ">")).()
    |> (&Regex.replace(~r/&amp;/, &1, "&")).()
  end

  def from_timestamp(value) do
    with {int, ""} <- Integer.parse(value),
      {:ok, ts} <- DateTime.from_unix(int)
    do
      ts |> DateTime.to_naive |> NaiveDateTime.to_erl
    else
      {:error, _} -> value
    end
  end

  def inventory(:filters) do
    [{:ndt_to_erl, {:"Elixir.Filters", :ndt_to_erl}},
     {:string, {:"Elixir.Filters", :string}},
     {:mystriptags, {:"Elixir.Filters", :mystriptags}},
     {:myescape, {:"Elixir.Filters", :myescape}},
     {:xss, {:"Elixir.Filters", :xss}},
     {:md, {:"Elixir.Filters", :md}},
     {:from_timestamp, {:"Elixir.Filters", :from_timestamp}}]
  end

  def inventory(:tags) do
    [{:csrf_token, {:"Elixir.Filters", :csrf_token}}]
  end
end

