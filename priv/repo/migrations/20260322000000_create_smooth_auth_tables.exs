defmodule Chess.Repo.Migrations.CreateSmoothAuthUserTable do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :string, null: false
      add :username, :string, null: false

      timestamps()
    end

    create unique_index(:user, [:email])
    create unique_index(:user, [:username])
  end
end
