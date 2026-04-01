defmodule SmoothAuth.Users do
  @moduledoc false

  import Ecto.Changeset, only: [apply_action: 2]

  alias SmoothAuth.{Subject, User}
  alias Chess.Repo

  def get_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: normalize_email(email))
  end

  def get_by_id(id), do: Repo.get(User, id)

  def user_exists_by_email?(email) when is_binary(email) do
    match?(%User{}, get_by_email(email))
  end

  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def validate_signup_attrs(email, username) do
    changeset = User.changeset(%User{}, %{email: email, username: username})

    case apply_action(changeset, :insert) do
      {:ok, user} -> {:ok, %{email: user.email, username: user.username}}
      {:error, changeset} -> {:error, {:validation, format_errors(changeset)}}
    end
  end

  def validate_email(email) do
    email = normalize_email(email)

    if is_binary(email) and Regex.match?(~r/^[^\s]+@[^\s]+\.[^\s]+$/, email) do
      {:ok, email}
    else
      {:error, {:validation, %{email: ["has invalid format"]}}}
    end
  end

  def to_subject(%User{id: id, email: email, username: username}) do
    %Subject{user_id: id, email: email, username: username}
  end

  defp normalize_email(email) when is_binary(email),
    do: email |> String.trim() |> String.downcase()

  defp normalize_email(_), do: nil

  defp format_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r/%{(\w+)}/, message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
