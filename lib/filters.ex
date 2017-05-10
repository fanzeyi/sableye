defmodule Filters do
  @behaviour :erlydtl_library

  require Logger

  def version() do
    1
  end

  def ndt_to_erl(value) do
    value |> NaiveDateTime.to_erl
  end

  def inventory(:filters) do
    [{:ndt_to_erl, {:"Elixir.Filters", :ndt_to_erl}}]
  end

  def inventory(:tags) do
    []
  end
end

