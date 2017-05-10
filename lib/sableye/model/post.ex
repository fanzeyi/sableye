defmodule Sableye.Model.Post do
  use Ecto.Schema

  import Ecto.Changeset

  alias Sableye.Model

  schema "posts" do
    field :title
    field :content
    belongs_to :user, Model.User
    timestamps
  end

  def changeset(post, params \\ %{}) do
    post
    |> cast(params, [:title, :content])
    |> put_assoc(:user, params["user"])
    |> validate_required([:title, :content], message: "%{label} can't be blank")
    |> validate_length(:title, min: 8, message: "%{label} should be least %{count} characters")
  end
end
