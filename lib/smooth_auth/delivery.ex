defmodule SmoothAuth.Delivery do
  @moduledoc false

  @callback deliver_code(String.t(), atom(), String.t(), map()) :: :ok | {:error, term()}

  def deliver_code(email, purpose, code, metadata \\ %{}) do
    adapter().deliver_code(email, purpose, code, metadata)
  end

  defp adapter do
    Application.fetch_env!(:chess, SmoothAuth)[:delivery_adapter]
  end
end
