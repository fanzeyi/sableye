defmodule Sableye.Model.Post do
  use Ecto.Schema

  schema "posts" do
    field :title
    field :content
    belongs_to :user, User
  end
end
