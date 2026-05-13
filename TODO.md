# SmoothAuth.Cache

## Requirements

1. Cache should hold in-memory state for active sessions and signup-requests, these should never be persisted on disc
2. Active sessions and signup-requests should not be persisted
3. However, cache should have a mechanism that helps it restore its state, perhaps some temporary file or other mechanism, such that when either cache process fails or beam vm crashes, it is able to restore the state

- For now cache exists as a GenServer that holds state in a map
- Should implement using :ets later
- Add some failure mechanic, Supervisor restarts cache as it was before rather than completely cleaning it up
