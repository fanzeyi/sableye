defmodule Sableye.Model.User do
  use Ecto.Schema

  schema "users" do
    field :email
    field :username
    field :password
  end
end
