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

  defp generate_totp_secret() do
    :crypto.hmac(:sha,
                 Application.get_env(:sableye, :totp_key, "THIS SHOULD NOT BE USED"),
                 :crypto.strong_rand_bytes(32)) |> Base.encode32
  end

  def totp(:get, conn) do
    conn |> render(:totp, [secret: generate_totp_secret()])
  end

  def totp(:post, conn) do
    with {:ok, secret} <- get_param(conn.params, "secret"),
      {:ok, code} <- get_param(conn.params, "code"),
      true <- :pot.valid_totp(code, secret)
    do
      user = conn.assigns[:user]
      user = user |> Model.User.add_totp(secret)

      Model.update user

      conn |> redirect("/")
    else
      false ->
        conn |> render(:totp, [secret: Map.get(conn.params, "secret", generate_totp_secret()),
                               errors: ["One-time code is incorrect"]])
      {:error, error} ->
        conn |> render(:totp, [secret: Map.get(conn.params, "secret", generate_totp_secret()),
                               errors: [error]])
    end
  end
end
