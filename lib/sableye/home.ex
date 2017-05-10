defmodule Sableye.Home do
  import Sableye.View
  import Ecto.Query

  alias Sableye.Model

  require Logger

  def home(conn) do
    query = Model.Post
    |> preload(:user)
    |> order_by(desc: :id)
    |> limit(5)

    posts = Model.all(query)

    Logger.debug "Posts: " <> inspect(posts)

    #posts = Enum.map(posts, fn post -> post.inserted_at = post.insert_at |> NaiveDateTime.to_erl end)

    conn |> render(:index, [posts: posts])
  end
end
