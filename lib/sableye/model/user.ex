defmodule Sableye.Model.User do
  use Ecto.Schema

  alias Comeonin.Bcrypt
  alias Sableye.Model
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]

  require Logger

  schema "users" do
    field :email
    field :username
    field :password
    field :role
    field :tos, :string, virtual: true
    field :"g-recaptcha-response", :string, virtual: true
    has_many :posts, Model.Post
  end

  def validate_recaptcha(changeset) do
    validate_change changeset, :"g-recaptcha-response", fn :"g-recaptcha-response", code ->
      Logger.info "Code is " <> inspect(code)
      case Recaptcha.verify(code) do
        {:ok, _} -> []
        {:error, _} -> [:"g-recaptcha-response", "reCAPTCHA challenge failed."]
      end
    end
  end

  def changeset(user, params \\ %{}) do
    Logger.debug inspect(params)
    user
    |> cast(params, [:email, :username, :password, :tos, :"g-recaptcha-response"])
    |> validate_required([:"g-recaptcha-response"], message: "reCAPTCHA challenge failed.")
    |> validate_recaptcha()
    |> validate_required([:email, :username, :password], message: "%{label} can't be blank")
    |> validate_length(:password, min: 8, message: "%{label} should be least %{count} characters")
    |> update_change(:password, &Bcrypt.hashpwsalt/1)
    |> validate_required([:tos], message: "Term of Service must be accepted")
    |> validate_format(:tos, ~r/^on$/, message: "Term of Service must be accepted")
    |> validate_format(:email, ~r/\S*@\S*/, message: "%{label} is invalid")
    |> validate_format(:username, ~r/[a-zA-Z0-9]*/, message: "%{label} can't contain space")
    |> unique_constraint(:email, message: "%{label} has already been taken")
    |> unique_constraint(:username, message: "%{label} has already been taken")
  end

  def checkpw(user, pass) do
    case Bcrypt.checkpw(pass, user.password) do
      true -> {:ok, ""}
      false -> {:error, "Username or password is incorrect"}
    end
  end

  def get_by_email_or_username(username) do
    query = from u in Sableye.Model.User,
      where: u.username == ^username or u.email == ^username,
      select: u

    case Sableye.Model.one(query) do
      nil -> {:error, "User is not found"}
      user -> {:ok, user}
    end
  end
end
