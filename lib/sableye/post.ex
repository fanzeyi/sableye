defmodule Sableye.Post do
  import Sableye.View
  import Plug.Conn

  alias Sableye.Model

  require Logger

  def create(:get, conn) do
    conn |> render(:create)
  end

  def create(:post, conn) do
    Logger.debug inspect(conn.params)

    changeset = Model.Post.changeset(%Model.Post{},
                                     Map.put(conn.params, "user", conn.assigns[:user]))

    case Model.insert(changeset) do
      {:ok, _} ->
        redirect(conn, "/")
      {:error, changeset} ->
        conn |> render(:create, [model: conn.params,
                                 errors: format_errors(changeset.errors)])
    end
  end

  def show(:get, conn) do
    Logger.info inspect(conn)
    with {:ok, post_id} <- get_param(conn.path_params, "post_id"),
      {id, ""} <- Integer.parse(post_id),
      {:ok, post} <- Model.get(Model.Post, id) |> ok_non_empty
    do
      conn |> render(:show_post, [post: post])
    else
      _ -> conn |> render(:"404", [])
    end
  end
end
