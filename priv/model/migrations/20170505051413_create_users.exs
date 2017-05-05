defmodule Sableye.Model.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users)do
      add :email, :string
      add :username, :string
      add :password, :string
    end
  end
end
