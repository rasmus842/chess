defmodule ChessWeb.AuthController do
  use ChessWeb, :controller

  def request_signup(conn, %{"email" => email, "username" => username}) do
    case SmoothAuth.request_signup(email, username) do
      {:ok, :accepted} ->
        conn
        |> put_status(:accepted)
        |> json(%{status: "ok"})

      {:error, reason} ->
        render_error(conn, reason)
    end
  end

  def request_signup(conn, _params),
    do: render_error(conn, {:validation, %{email: ["is required"], username: ["is required"]}})

  def verify_signup(conn, %{"email" => email, "code" => code}) do
    case SmoothAuth.verify_signup_code(email, code) do
      {:ok, tokens} -> json(conn, token_response(tokens))
      {:error, reason} -> render_error(conn, reason)
    end
  end

  def verify_signup(conn, _params),
    do: render_error(conn, {:validation, %{email: ["is required"], code: ["is required"]}})

  def request_login(conn, %{"email" => email}) do
    case SmoothAuth.request_login(email) do
      {:ok, :accepted} ->
        conn
        |> put_status(:accepted)
        |> json(%{status: "ok"})

      {:error, reason} ->
        render_error(conn, reason)
    end
  end

  def request_login(conn, _params),
    do: render_error(conn, {:validation, %{email: ["is required"]}})

  def verify_login(conn, %{"email" => email, "code" => code}) do
    case SmoothAuth.verify_login_code(email, code) do
      {:ok, tokens} -> json(conn, token_response(tokens))
      {:error, reason} -> render_error(conn, reason)
    end
  end

  def verify_login(conn, _params),
    do: render_error(conn, {:validation, %{email: ["is required"], code: ["is required"]}})

  def refresh(conn, %{"refresh_token" => refresh_token}) do
    case SmoothAuth.refresh_session(refresh_token) do
      {:ok, tokens} -> json(conn, token_response(tokens))
      {:error, reason} -> render_error(conn, reason)
    end
  end

  def refresh(conn, _params),
    do: render_error(conn, {:validation, %{refresh_token: ["is required"]}})

  def logout(conn, %{"refresh_token" => refresh_token}) do
    case SmoothAuth.logout(refresh_token) do
      {:ok, :logged_out} -> json(conn, %{status: "ok"})
      {:error, reason} -> render_error(conn, reason)
    end
  end

  def logout(conn, _params),
    do: render_error(conn, {:validation, %{refresh_token: ["is required"]}})

  def me(conn, _params) do
    json(conn, %{user: subject_json(conn.assigns.current_subject)})
  end

  defp token_response(%{
         access_token: access_token,
         refresh_token: refresh_token,
         subject: subject
       }) do
    %{
      access_token: access_token,
      refresh_token: refresh_token,
      user: subject_json(subject)
    }
  end

  defp subject_json(subject) do
    %{
      id: subject.user_id,
      email: subject.email,
      username: subject.username
    }
  end

  defp render_error(conn, {:validation, errors}) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "validation_failed", details: errors})
  end

  defp render_error(conn, :invalid_or_expired_code) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: "invalid_or_expired_code"})
  end

  defp render_error(conn, :too_many_attempts) do
    conn
    |> put_status(:too_many_requests)
    |> json(%{error: "too_many_attempts"})
  end

  defp render_error(conn, :invalid_access_token) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "invalid_access_token"})
  end

  defp render_error(conn, :invalid_refresh_token) do
    conn
    |> put_status(:unauthorized)
    |> json(%{error: "invalid_refresh_token"})
  end

  defp render_error(conn, {:delivery_failed, _reason}) do
    conn
    |> put_status(:service_unavailable)
    |> json(%{error: "delivery_failed"})
  end

  defp render_error(conn, reason) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{error: to_string(reason)})
  end
end
