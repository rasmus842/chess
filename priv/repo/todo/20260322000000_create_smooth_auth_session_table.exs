defmodule Chess.Repo.TodoMigrations.CreateSmoothAuthSessionTable do
  use Ecto.Migration

  def change do
    create table(:session) do
      add :user_id, references(:user, on_delete: :delete_all), null: false
      add :token_hash, :string, null: false
      add :expires_at, :utc_datetime_usec, null: false
      add :revoked_at, :utc_datetime_usec
      add :replaced_by_token_hash, :string

      timestamps(updated_at: false)
    end

    create unique_index(:session, [:token_hash])
    create index(:session, [:user_id])
  end
end
