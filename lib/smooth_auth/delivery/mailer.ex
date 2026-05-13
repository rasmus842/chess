defmodule SmoothAuth.Delivery.Mailer do
  @moduledoc false

  @behaviour SmoothAuth.Delivery

  import Swoosh.Email

  alias Chess.Mailer

  @impl true
  def deliver_code(email, purpose, code, metadata) do
    {subject, body} = message_for(purpose, code, metadata)
    {from_name, from_email} = from_address()

    email =
      new()
      |> from({from_name, from_email})
      |> to(email)
      |> subject(subject)
      |> text_body(body)

    case Mailer.deliver(email) do
      {:ok, _result} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp message_for(:signup_verify_email, code, metadata) do
    username = Map.get(metadata, :username)

    {
      "Verify your email",
      "Your verification code is #{code}. Use it to finish signing up#{username_suffix(username)}."
    }
  end

  defp message_for(:login, code, _metadata) do
    {"Your login code", "Your login code is #{code}. Enter it to continue signing in."}
  end

  defp username_suffix(nil), do: ""
  defp username_suffix(username), do: " as #{username}"

  defp from_address do
    Application.fetch_env!(:chess, SmoothAuth)[:email_from]
  end
end
