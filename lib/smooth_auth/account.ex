defmodule SmoothAuth.Account do
  use TypedStruct

  @type account_id :: pos_integer()

  typedstruct do
    field :id, account_id(), enforce: true
    field :email, String.t(), enforce: true
    field :username, String.t(), enforce: true
  end

end
