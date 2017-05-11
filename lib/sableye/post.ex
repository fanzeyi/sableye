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

  def get_post(conn, label \\ "post_id", all \\ false) do
    with {:ok, post_id} <- get_param(conn.path_params, label),
      {id, ""} <- Integer.parse(post_id),
      {:ok, post} <- Model.get(Model.Post, id) |> ok_non_empty
    do
      case (not all) and post.deleted do
        true -> {:error, nil}
        false -> {:ok, post}
      end
    else
      _ -> {:error, nil}
    end
  end

  def show(:get, conn) do
    case get_post(conn) do
      {:ok, post} ->
        post = Model.preload post, :user
        conn |> render(:show_post, [post: post])
      {:error, _} -> conn |> render(:"404", [])
    end
  end

  def delete(:get, conn) do
    case get_post(conn) do
      {:ok, post} ->
        post = Model.preload post, :user
        current_user = conn.assigns[:user]

        case post.user.id == current_user.id or current_user.role == "admin" do
          false -> conn |> render(:"404", [])
          true ->
            post = Model.Post.delete post
            Model.update post
            conn |> redirect("/")
        end

      {:error, _} -> conn |> render(:"404", [])
    end
  end
end
