defmodule Sableye.User do
  import Plug.Conn

  import Sableye.View
  import Sableye.Util

  use Timex

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
      Logger.info inspect(user)
      if is_nil(user.totp) do
        conn
        |> put_session(:user, user.id)
        |> redirect("/")
      else
        conn
        |> put_session(:totp_user, user.id)
        |> put_session(:totp_time, :os.system_time(:seconds))
        |> redirect("/totp_login")
      end
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
    secret = generate_totp_secret()
    Logger.debug :pot.totp(secret)
    conn |> render(:totp, [secret: secret])
  end

  def totp(:post, conn) do
    with {:ok, secret} <- get_param(conn.params, "secret"),
      {:ok, code} <- get_param(conn.params, "code"),
      true <- :pot.valid_totp(code, secret)
    do
      user = conn.assigns[:user]
      user = user |> Model.User.add_totp(secret)

      Logger.debug inspect(user)

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

  def totp_login(:get, conn) do
    with {:ok, user_id} <- get_session?(conn, :totp_user),
      {:ok, user} <- error_tuple(Model.get(Model.User, user_id)),
      {:ok, _} <- error_tuple(!is_nil(user.totp)),
      {:ok, totp_ts} <- get_session?(conn, :totp_time),
      {:ok, ts} <- DateTime.from_unix(totp_ts),
      {:ok, _} <- error_tuple(Timex.diff(Timex.now, ts, :seconds) < 120)
    do
      conn |> render(:totp_login)
    else
      {:error, err} ->
      Logger.error inspect(err)
      conn
      |> delete_session(:totp_user)
      |> delete_session(:totp_time)
      |> redirect("/")
    end
  end

  def totp_login(:post, conn) do
    with {:ok, user_id} <- get_session?(conn, :totp_user),
      {:ok, user} <- error_tuple(Model.get(Model.User, user_id)),
      {:ok, _} <- error_tuple(!is_nil(user.totp)),
      {:ok, totp_ts} <- get_session?(conn, :totp_time),
      {:ok, ts} <- DateTime.from_unix(totp_ts),
      {:ok, _} <- error_tuple(Timex.diff(Timex.now, ts, :seconds) < 120),
      {:ok, code} <- get_param(conn.params, "code"),
      {:ok, _} <- error_tuple(:pot.valid_totp(code, user.totp))
    do
      conn
      |> delete_session(:totp_user)
      |> delete_session(:totp_time)
      |> put_session(:user, user.id)
      |> redirect("/")
      |> render(:totp_login)
    else
      _ -> conn
        |> delete_session(:totp_user)
        |> delete_session(:totp_time)
        |> redirect("/login")
    end
  end
end
