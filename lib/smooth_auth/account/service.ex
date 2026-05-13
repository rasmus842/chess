defmodule SmoothAuth.Account.Service do

  alias SmoothAuth.Account.NewAccount
  alias SmoothAuth.Account
  alias SmoothAuth.Validation
  alias SmoothAuth.Signup.Request
  
  @callback create_new_account(Request.t()) :: {:ok, Account.t()} | {:error, Validation.errors()}

  @callback get_account(Account.account_id()) :: {:ok, Account.t()} | {:error, :not_found}
end
