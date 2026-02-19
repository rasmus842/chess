import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import tsconfigPaths from "vite-tsconfig-paths";
import tailwindcss from "@tailwindcss/vite";

// https://vite.dev/config/
export default defineConfig({
  plugins: [react(), tsconfigPaths(), tailwindcss()],
  server: {
    proxy: {
      "/api": "http://localhost:4000",
      "/socket": {
        target: "http://localhost:4000",
        ws: true,
      },
    },
  },
});
