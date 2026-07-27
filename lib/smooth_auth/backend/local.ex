defmodule SmoothAuth.Backend.Local do
  @moduledoc false

  @behaviour SmoothAuth.Backend

  alias SmoothAuth.Backend.Local.{Signup, Sessions}

  @impl true
  def request_signup(request) do
    Signup.new_signup(request)
  end

  @impl true
  def verify_signup(verification) do
    Signup.verify_signup(verification)
  end

end
