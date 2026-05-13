defmodule SmoothAuth.Signup.Verification do
  use TypedStruct

  alias SmoothAuth.Signup.{Request, VerificationCode}

  typedstruct do
    field :request, Request.t(), enforce: true
    field :code, VerificationCode.code(), enforce: true
  end
  
end
