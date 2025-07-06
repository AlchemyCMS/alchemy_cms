import { defineConfig } from "vitest/config"
import path from "node:path"

export default defineConfig({
  test: {
    environment: "jsdom",
    globals: true,
    root: "spec/javascript/alchemy_admin/",
    setupFiles: ["setup.js"]
  },
  resolve: {
    alias: {
      alchemy_admin: path.resolve(__dirname, "app/javascript/alchemy_admin"),
      assets: path.resolve(__dirname, "vendor/assets/javascripts"),
      vendor: path.resolve(__dirname, "vendor/javascript")
    }
  },
  define: {
    "global.Alchemy": {}
  }
})
