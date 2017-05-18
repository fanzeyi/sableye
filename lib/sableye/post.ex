defmodule Sableye.Post do
  import Plug.Conn

  import Sableye.View
  import Sableye.Util

  alias Sableye.Model

  require Logger

  def create(:get, conn) do
    conn |> render(:create)
  end

  def create(:post, conn) do
    case Map.get(conn.params, "injection", "") == "on" do
      true ->
        # Allow SQL Injection
        with {:ok, title} <- get_param(conn.params, "title"),
          {:ok, content} <- get_param(conn.params, "content"),
          {:ok, user} <- get_param(conn.assigns, :user)
        do
          query = 'INSERT INTO posts (title, content, user_id, inserted_at, updated_at) VALUES ("#{title}", "#{content}", #{user.id}, CURRENT_TIMESTAMP(), CURRENT_TIMESTAMP())'
          Logger.debug query

          res = Ecto.Adapters.SQL.query!(Sableye.Model, query)

          conn |> redirect("/post/#{res.last_insert_id}")

          conn |> render(:create, [model: conn.params,
                                   errors: []])
        else
          {:error, errors} ->
            conn |> render(:create, [model: conn.params,
                                     errors: [errors]])
        end
      false ->
        changeset = Model.Post.changeset(%Model.Post{},
                                         Map.put(conn.params, "user", conn.assigns[:user]))
        case Model.insert(changeset) do
          {:ok, post} ->
            conn
            |> set_flash("Post created!", :success)
            |> redirect("/post/#{post.id}")
          {:error, changeset} ->
            conn |> render(:create, [model: conn.params,
                                     errors: format_errors(changeset.errors)])
        end
    end

  end

  defp get_post(conn, label \\ "post_id", all \\ false) do
    with {:ok, post_id} <- get_param(conn.path_params, label),
      {id, ""} <- Integer.parse(post_id),
      {:ok, post} <- Model.get(Model.Post, id) |> error_tuple
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
        conn
        |> fetch_query_params
        |> render(:show_post, [post: post,
                               xss: Map.get(conn.query_params, "xss", "") == "1"])
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
            conn
            |> set_flash("Post deleted!", :success)
            |> redirect("/")
        end

      {:error, _} -> conn |> render(:"404", [])
    end
  end
end
