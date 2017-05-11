defmodule Sableye.Model.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :text
      add :user_id, references(:users)
      add :deleted, :boolean, null: false, default: false

      timestamps()
    end
  end

  def down do
    drop table(:posts)
  end
end
