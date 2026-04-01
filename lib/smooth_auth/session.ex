defmodule SmoothAuth.Session do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "session" do
    field :token_hash, :string
    field :expires_at, :utc_datetime_usec
    field :revoked_at, :utc_datetime_usec
    field :replaced_by_token_hash, :string

    belongs_to :user, SmoothAuth.User

    timestamps(updated_at: false)
  end

  def changeset(session, attrs) do
    session
    |> cast(attrs, [:user_id, :token_hash, :expires_at, :revoked_at, :replaced_by_token_hash])
    |> validate_required([:user_id, :token_hash, :expires_at])
    |> unique_constraint(:token_hash)
  end
end
