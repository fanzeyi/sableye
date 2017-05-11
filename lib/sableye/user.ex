defmodule Sableye.User do
  import Plug.Conn
  import Sableye.View

  alias Sableye.Model

  require Logger

  def _register(:get, conn) do
    conn |> render(:_register, [recaptcha: Recaptcha.Template.display()])
  end

  def _register(:post, conn) do
    changeset = Model.User.changeset(%Model.User{}, conn.params)

    case Model.insert(changeset) do
      {:ok, user} ->
        if user.id == 1 do
          Model.update user |> Ecto.Changeset.change(role: "admin")
        end

        redirect(conn, "/login")
      {:error, changeset} ->
        conn |> render(:_register, [model: conn.params,
                                    errors: format_errors(changeset.errors),
                                    recaptcha: Recaptcha.Template.display()])
    end
  end

  def login(:get, conn) do
    conn |> render(:login)
  end

  def login(:post, conn) do
    with {:ok, username} <- get_param(conn.params, "username"),
         {:ok, password} <- get_param(conn.params, "password"),
         {:ok, user} <- Model.User.get_by_email_or_username(username),
         {:ok, _} <- Model.User.checkpw(user, password)
    do
      conn
      |> put_session(:user, user.id)
      |> redirect("/")
    else
      {:error, error} ->
        conn |> render(:login, [model: conn.params,
                                errors: [error]])
    end
  end

  def logout(:get, conn) do
    conn
    |> delete_session(:user)
    |> redirect("/")
  end
end
