defmodule SmoothAuth.Signup.Request do
  use TypedStruct

  typedstruct do
    field :email, String.t(), enforce: true
    field :username, String.t(), enforce: true
  end
end
