defmodule SmoothAuth.Backend.Local.Accounts do
  @behaviour SmoothAuth.Account.Service

  alias SmoothAuth.{Account, Users, User, Validation}

  @impl true
  def create_new_account(signup_request) do
    case Users.create_user(signup_request) do
      {:ok, user} -> {:ok, map_to_account(user)}
      {:error, changeset} -> {:error, Validation.format_ecto_errors(changeset)}
    end
  end

  @impl true
  def get_account(account_id) do
    case Users.get_by_id(account_id) do
      nil -> {:error, :not_found}
      user -> {:ok, map_to_account(user)}
    end
  end

  defp map_to_account(%User{id: id, email: email, username: username}) do
    %Account{id: id, email: email, username: username}
  end
end
