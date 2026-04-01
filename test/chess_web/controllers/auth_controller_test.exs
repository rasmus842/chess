defmodule ChessWeb.AuthControllerTest do
  use ChessWeb.ConnCase, async: false

  import Swoosh.TestAssertions

  alias SmoothAuth.{User, Users}
  alias Chess.Repo

  test "signup request sends code and verify creates user", %{conn: conn} do
    email = unique_email()

    conn = post(conn, "/api/auth/signup/request", %{email: email, username: "rookstar"})
    assert json_response(conn, 202) == %{"status" => "ok"}

    code = delivered_code!()

    conn = post(build_conn(), "/api/auth/signup/verify", %{email: email, code: code})
    body = json_response(conn, 200)

    assert %{
             "access_token" => access_token,
             "refresh_token" => refresh_token,
             "user" => %{"email" => ^email, "username" => "rookstar"}
           } = body

    assert is_binary(access_token)
    assert is_binary(refresh_token)
    assert %User{email: ^email, username: "rookstar"} = Repo.get_by(User, email: email)

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{access_token}")
      |> get("/api/auth/me")

    assert %{"user" => %{"email" => ^email, "username" => "rookstar"}} = json_response(conn, 200)
  end

  test "duplicate signup keeps the original username while active", %{conn: conn} do
    email = unique_email()

    conn = post(conn, "/api/auth/signup/request", %{email: email, username: "first_name"})
    assert json_response(conn, 202) == %{"status" => "ok"}

    code = delivered_code!()

    conn =
      post(build_conn(), "/api/auth/signup/request", %{email: email, username: "second_name"})

    assert json_response(conn, 202) == %{"status" => "ok"}
    assert_no_email_sent()

    conn = post(build_conn(), "/api/auth/signup/verify", %{email: email, code: code})

    assert %{"user" => %{"username" => "first_name"}} = json_response(conn, 200)
    assert %User{username: "first_name"} = Repo.get_by(User, email: email)
  end

  test "login request is generic for unknown email", %{conn: conn} do
    conn = post(conn, "/api/auth/login/request", %{email: unique_email()})

    assert json_response(conn, 202) == %{"status" => "ok"}
    assert_no_email_sent()
  end

  test "login verify returns tokens for existing user", %{conn: conn} do
    email = unique_email()
    {:ok, _user} = Users.create_user(%{email: email, username: "bishop_bot"})

    conn = post(conn, "/api/auth/login/request", %{email: email})
    assert json_response(conn, 202) == %{"status" => "ok"}

    code = delivered_code!()

    conn = post(build_conn(), "/api/auth/login/verify", %{email: email, code: code})
    body = json_response(conn, 200)

    assert %{
             "access_token" => _access_token,
             "refresh_token" => _refresh_token,
             "user" => %{"username" => "bishop_bot"}
           } = body
  end

  test "refresh rotates tokens and logout revokes the session", %{conn: conn} do
    email = unique_email()

    conn = post(conn, "/api/auth/signup/request", %{email: email, username: "queenmove"})
    assert json_response(conn, 202) == %{"status" => "ok"}

    code = delivered_code!()

    conn = post(build_conn(), "/api/auth/signup/verify", %{email: email, code: code})
    auth_body = json_response(conn, 200)

    conn =
      post(build_conn(), "/api/auth/refresh", %{"refresh_token" => auth_body["refresh_token"]})

    refreshed = json_response(conn, 200)

    assert refreshed["refresh_token"] != auth_body["refresh_token"]

    conn =
      build_conn()
      |> put_req_header("authorization", "Bearer #{refreshed["access_token"]}")
      |> get("/api/auth/me")

    assert %{"user" => %{"email" => ^email, "username" => "queenmove"}} = json_response(conn, 200)

    conn =
      post(build_conn(), "/api/auth/refresh", %{"refresh_token" => auth_body["refresh_token"]})

    assert json_response(conn, 401) == %{"error" => "invalid_refresh_token"}

    conn =
      post(build_conn(), "/api/auth/logout", %{"refresh_token" => refreshed["refresh_token"]})

    assert json_response(conn, 200) == %{"status" => "ok"}

    conn =
      post(build_conn(), "/api/auth/refresh", %{"refresh_token" => refreshed["refresh_token"]})

    assert json_response(conn, 401) == %{"error" => "invalid_refresh_token"}
  end

  test "me endpoint requires an access token", %{conn: conn} do
    conn = get(conn, "/api/auth/me")

    assert json_response(conn, 401) == %{"error" => "unauthorized"}
  end

  defp delivered_code! do
    assert_received {:email, email}

    Regex.run(~r/(\d{6})/, email.text_body, capture: :all_but_first)
    |> List.first()
  end

  defp unique_email do
    "user#{System.unique_integer([:positive])}@example.com"
  end
end
