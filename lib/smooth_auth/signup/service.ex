defmodule SmoothAuth.Signup.Service do
  alias SmoothAuth.Signup.{Request, Verification}
  alias SmoothAuth.Account

  @type verification_error ::
          :not_found
          | :invalid_signup_request
          | :invalid_verification_code

  @callback new_signup(Request.t()) :: :ok | {:error, term()}

  @callback verify_signup(Verification.t()) :: {:ok, Account.t()} | {:error, verification_error()}
end
