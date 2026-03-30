import { expect, test } from "@playwright/test";

test.describe("auth flow", () => {
  test("signup success redirects to verify", async ({ page }) => {
    await page.route("**/api/auth/signup", async (route) => {
      await route.fulfill({ status: 200, body: "" });
    });

    await page.goto("/auth/signup");
    await page.getByLabel("Username").fill("rookie99");
    await page.getByLabel("Email").fill("rookie99@example.com");
    await page.getByRole("button", { name: "Sign up" }).click();

    await expect(page).toHaveURL(/\/auth\/verify$/);
    await expect(page.getByRole("heading", { name: "Verify" })).toBeVisible();
  });

  test("login success redirects to verify", async ({ page }) => {
    await page.route("**/api/auth/login", async (route) => {
      await route.fulfill({ status: 200, body: "" });
    });

    await page.goto("/auth/login");
    await page.getByLabel("Username or email").fill("rookie99@example.com");
    await page.getByRole("button", { name: "Login" }).click();

    await expect(page).toHaveURL(/\/auth\/verify$/);
    await expect(page.getByRole("heading", { name: "Verify" })).toBeVisible();
  });

  test("verify failure stays on page and shows generic inline error", async ({ page }) => {
    await page.route("**/api/auth/verify", async (route) => {
      await route.fulfill({ status: 422, body: "" });
    });

    await page.goto("/auth/verify");
    await page.getByLabel("Username").fill("rookie99");
    await page.getByLabel("Email").fill("rookie99@example.com");
    await page.getByLabel("Verification code").fill("123456");
    await page.getByRole("button", { name: "Verify" }).click();

    await expect(page).toHaveURL(/\/auth\/verify$/);
    await expect(page.getByText("Invalid verification code.")).toBeVisible();
  });

  test("verify success redirects home", async ({ page }) => {
    await page.route("**/api/auth/verify", async (route) => {
      await route.fulfill({ status: 200, body: "" });
    });

    await page.goto("/auth/verify");
    await page.getByLabel("Username").fill("rookie99");
    await page.getByLabel("Email").fill("rookie99@example.com");
    await page.getByLabel("Verification code").fill("123456");
    await page.getByRole("button", { name: "Verify" }).click();

    await expect(page).toHaveURL(/\/$/);
    await expect(page.getByRole("heading", { name: "Chess app" })).toBeVisible();
  });
});
