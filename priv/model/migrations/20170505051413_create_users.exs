defmodule Sableye.Model.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :username, :string, null: false
      add :password, :string
      add :role, :string, null: false, default: "user"
      add :totp, :string
    end

    create unique_index(:users, [:email])
    create unique_index(:users, [:username])
  end
end
