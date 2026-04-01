defmodule SmoothAuth.Subject do
  @moduledoc false

  @enforce_keys [:user_id, :email, :username]
  defstruct [:user_id, :email, :username]

  @type t :: %__MODULE__{
          user_id: integer(),
          email: String.t(),
          username: String.t(),
        }
end
