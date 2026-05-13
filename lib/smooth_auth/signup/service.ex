defmodule SmoothAuth.Signup.Service do
  alias SmoothAuth.Signup.{Request, Verification, VerificationCode}
  alias SmoothAuth.Account

  @type signup_error :: :duplicate_signup

  @type verification_error ::
          :invalid_signup_request
          | :invalid_verification_code

  @callback new_signup(Request.t()) :: {:ok, VerificationCode.code()} | {:error, signup_error()}

  @callback verify_signup(Verification.t()) :: {:ok, Account.t()} | {:error, verification_error()}
end
