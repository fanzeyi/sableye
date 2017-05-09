defmodule Sableye.Home do
  import Sableye.View

  def home(conn) do
    conn |> render(:index)
  end
end
