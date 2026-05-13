defmodule SmoothAuth.Account.Service do

  alias SmoothAuth.Account.NewAccount
  alias SmoothAuth.Account
  
  @callback create_new_account(NewAccount.t()) :: {:ok, Account.t()} | {:error, term()}

  @callback get_account(Account.account_id()) :: {:ok, Account.t()} | {:error, :not_found}
end
