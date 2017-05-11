defmodule Sableye.Home do
  import Sableye.View
  import Ecto.Query

  alias Sableye.Model

  require Logger

  def home(conn) do
    query = Model.Post
    |> where(deleted: false)
    |> order_by(desc: :id)
    |> limit(5)
    |> preload(:user)

    posts = Model.all(query)

    conn |> render(:index, [posts: posts])
  end
end
