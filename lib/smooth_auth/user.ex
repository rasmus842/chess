defmodule SmoothAuth.User do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :email, :string
    field :username, :string

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :username])
    |> update_change(:email, &normalize_email/1)
    |> update_change(:username, &normalize_username/1)
    |> validate_required([:email, :username])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/)
    |> validate_length(:email, max: 160)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/)
    |> validate_length(:username, min: 3, max: 32)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
  end

  defp normalize_email(nil), do: nil
  defp normalize_email(email), do: email |> String.trim() |> String.downcase()

  defp normalize_username(nil), do: nil
  defp normalize_username(username), do: String.trim(username)
end
