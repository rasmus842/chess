# Validation and TypeScript Template

Use this pattern when data enters the UI from a loosely typed boundary like an API response, route params, or search params.

What it demonstrates:

- `zod` as the runtime validator
- TypeScript types inferred from the schema
- parsing `unknown` data at the boundary
- keeping internal code strongly typed after parsing

```ts
import { z } from "zod";

const userResponseSchema = z.object({
  id: z.string().min(1),
  email: z.string().trim().email(),
  profile: z.object({
    firstName: z.string().trim().min(1),
    lastName: z.string().trim().min(1),
  }),
});

export type UserResponse = z.infer<typeof userResponseSchema>;

export async function fetchUser(userId: string): Promise<UserResponse> {
  const response = await fetch(`/api/users/${userId}`);

  if (!response.ok) {
    throw new Error("Failed to load user");
  }

  const data: unknown = await response.json();
  return userResponseSchema.parse(data);
}
```

Search params example:

```ts
import { z } from "zod";

const searchParamsSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  query: z.string().trim().default(""),
  status: z.enum(["all", "active", "archived"]).default("all"),
});

export type SearchParams = z.infer<typeof searchParamsSchema>;

export function parseSearchParams(params: URLSearchParams): SearchParams {
  return searchParamsSchema.parse({
    page: params.get("page"),
    query: params.get("query"),
    status: params.get("status"),
  });
}
```

Notes:

- Accept `unknown` at the edge, then parse.
- Export inferred types from the schema instead of duplicating interfaces.
- Keep normalization near parsing so the rest of the app can stay simple.
