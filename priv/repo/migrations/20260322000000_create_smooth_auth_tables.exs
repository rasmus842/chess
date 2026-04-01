defmodule Chess.Repo.Migrations.CreateSmoothAuthTables do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :email, :string, null: false
      add :username, :string, null: false

      timestamps()
    end

    create unique_index(:user, [:email])
    create unique_index(:user, [:username])

    create table(:session) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :revoked_at, :utc_datetime_usec
      add :replaced_by_token_hash, :string

      timestamps(updated_at: false)
    end

    create unique_index(:smooth_auth_sessions, [:token_hash])
    create index(:smooth_auth_sessions, [:user_id])
  end
end
