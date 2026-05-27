defmodule SmoothAuth.Signup.CacheAdapter do
  @config Application.compile_env!(:smooth_auth, SmoothAuth)
  @implementation Keyword.fetch!(@config, :signup_cache)

  @behaviour SmoothAuth.Signup.Cache

  @impl true
  defdelegate verify_not_exists(request), to: @implementation

  @impl true
  defdelegate get_by_email(email), to: @implementation

  @impl true
  defdelegate put(request, code), to: @implementation

  @impl true
  defdelegate delete_by_email(email), to: @implementation

  @impl true
  defdelegate delete_all(emails), to: @implementation
end
