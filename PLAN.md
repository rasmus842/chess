## SmoothAuth implementation plan

### Phase 1: Lock the public contract
- Define `SmoothAuth` as the only auth entrypoint used by `Chess` and `ChessWeb`.
- Define `%SmoothAuth.Subject{}` as the normalized authenticated identity returned by `authenticate/1`.
- Define the stable public functions:
  - `request_signup/2`
  - `verify_signup_code/2`
  - `request_login/1`
  - `verify_login_code/2`
  - `refresh_session/1`
  - `logout/1`
  - `authenticate/1`
- Normalize all results to `{:ok, ...}` / `{:error, reason}` with transport-agnostic reason atoms.

### Phase 2: Define backend abstraction
- Create `SmoothAuth.Backend` behavior for the full contract.
- Make `SmoothAuth` delegate to a configured backend module.
- Start with `SmoothAuth.Backend.Local`.
- Reserve room for future backends:
  - local in-app
  - distributed Erlang/RPC
  - remote service
- Ensure `Chess` never references implementation modules directly.

### Phase 3: Model the data
- Add persisted `users` table with:
  - `email`
  - `username`
  - timestamps
- Enforce unique indexes on `email` and `username`.
- Add persisted refresh-session table, e.g. `smooth_auth_sessions`, with:
  - `user_id`
  - hashed refresh token
  - expires-at
  - revoked-at
  - replaced-by / rotation metadata
  - timestamps
- Do not persist signup requests or verification codes.

### Phase 4: Build in-memory challenge system
- Implement `SmoothAuth.Challenges` as a unified challenge service.
- Back it with ETS owned by a GenServer.
- Store challenge records keyed by email and purpose:
  - `purpose`
  - `email`
  - optional `username`
  - hashed code
  - expiry
  - attempts
  - resend throttling metadata
- Support at least:
  - `:signup_verify_email`
  - `:login`
- Add periodic cleanup or lazy expiry checks.

### Phase 5: Implement signup flow
- `request_signup(email, username)`:
  - if user already exists, return generic success
  - if pending signup exists and is unexpired, ignore the new request and preserve the original username
  - otherwise create pending signup challenge and send code
- `verify_signup_code(email, code)`:
  - verify challenge
  - create user row atomically
  - issue access + refresh tokens
  - delete/consume the challenge
- Handle race conditions cleanly around unique email/username constraints.

### Phase 6: Implement login flow
- `request_login(email)`:
  - always return generic success
  - only generate/send a challenge if the user exists
- `verify_login_code(email, code)`:
  - verify challenge
  - load user
  - issue access + refresh tokens
  - consume the challenge

### Phase 7: Implement token system
- Access token:
  - signed
  - short-lived
  - contains `sub`/`user_id`, `email`, `username`, `exp`
- Refresh token:
  - opaque random value
  - persisted hashed
  - rotated on every refresh
- `authenticate/1`:
  - verify access token
  - return `%SmoothAuth.Subject{}`
- `refresh_session/1`:
  - verify stored refresh token
  - rotate it
  - issue new access + refresh pair
- `logout/1`:
  - revoke the refresh session

### Phase 8: Define subject shape
- Add `%SmoothAuth.Subject{}` with stable fields such as:
  - `user_id`
  - `email`
  - `username`
- Keep it intentionally small so it can be serialized or returned by remote backends later without breaking consumers.

### Phase 9: Add delivery boundary
- Create `SmoothAuth.Delivery` behavior for sending email codes.
- Implement a local adapter using `Chess.Mailer`.
- Keep challenge generation separate from delivery so later a remote auth service can own email dispatch without changing the Chess-facing contract.

### Phase 10: Add Phoenix API endpoints
- Add controller endpoints:
  - `POST /api/auth/signup/request`
  - `POST /api/auth/signup/verify`
  - `POST /api/auth/login/request`
  - `POST /api/auth/login/verify`
  - `POST /api/auth/refresh`
  - `POST /api/auth/logout`
- Keep controllers thin: validate params, call `SmoothAuth`, map results to JSON.
- Return generic outward responses for request endpoints to avoid email enumeration.

### Phase 11: Add request authentication plug
- Implement `ChessWeb.Plugs.AuthenticateUser`.
- Read bearer token from `Authorization` header.
- Call `SmoothAuth.authenticate/1`.
- On success assign `%SmoothAuth.Subject{}` to `conn`.
- Use this plug on protected API routes.
- Keep controllers/channels dependent on assigned subject, not token internals.

### Phase 12: Prepare for future remote auth
- Keep all auth config-driven:
  - backend module
  - token secrets/settings
  - email delivery adapter
- Avoid leaking local-only assumptions into controllers or plugs.
- Design the backend contract so a future remote backend can return the same `%SmoothAuth.Subject{}` and token/session results.
- Treat `SmoothAuth` as the compatibility layer that must remain stable.

### Phase 13: Testing strategy
- Unit test challenge lifecycle:
  - create
  - ignore duplicate signup during active window
  - expire
  - verify
  - consume
- Unit test token issuing/authentication/refresh rotation/logout.
- Integration test controller flows for signup, login, refresh, logout.
- Plug tests for protected routes with valid/invalid tokens.
- Concurrency tests for duplicate signup verification and unique-constraint races.
- Mailer tests for code delivery.

### Suggested execution order
1. `SmoothAuth` facade, backend behavior, and `%SmoothAuth.Subject{}`
2. user + session schemas/migrations
3. in-memory challenge service
4. signup flow
5. login flow
6. token + refresh lifecycle
7. delivery adapter
8. auth controller endpoints
9. authenticate plug and protected routes
10. test hardening and config cleanup

### Default implementation values
- 6-digit numeric one-time codes
- signup/login code expiry around 10 minutes
- low retry limit per challenge
- refresh token rotation on every refresh
- short-lived access token, e.g. 15 minutes
