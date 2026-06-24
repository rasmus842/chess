defmodule SmoothAuth.Session do
  @moduledoc false

  use TypedStruct

  alias SmoothAuth.Subject

  @type session_id :: String.t()

  typedstruct do
    field :session_id, session_id(), enforce: true
    field :subject, Subject.t(), enforce: true
    field :created_at, DateTime.t(), enforce: true
    field :expires_at, DateTime.t(), enforce: true
  end
end
