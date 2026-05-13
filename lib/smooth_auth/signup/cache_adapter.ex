defmodule SmoothAuth.Signup.CacheAdapter do
  @config Application.compile_env!(:smooth_auth, SmoothAuth)
  @implementation Keyword.fetch!(@config, :signup_cache)

  @behaviour SmoothAuth.Signup.Cache

  @impl true
  defdelegate verify_not_exists(request), to: @implementation

  @impl true
  defdelegate get_existing(request), to: @implementation
  
  @impl true
  defdelegate put(request, code), to: @implementation
  
  @impl true
  defdelegate delete(request), to: @implementation
  
  @impl true
  defdelegate delete_all(requests), to: @implementation
  
end
