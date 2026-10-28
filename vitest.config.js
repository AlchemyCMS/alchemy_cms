import { defineConfig } from "vitest/config"
import path from "node:path"

const resolve = {
  alias: {
    alchemy_admin: path.resolve(__dirname, "app/javascript/alchemy_admin"),
    assets: path.resolve(__dirname, "vendor/assets/javascripts"),
    vendor: path.resolve(__dirname, "vendor/javascript"),
    "@hotwired/turbo-rails": path.resolve(
      __dirname,
      "spec/javascript/alchemy_admin/turbo_rails_stub.js"
    )
  }
}

export default defineConfig({
  test: {
    projects: [
      {
        resolve,
        define: {
          "global.Alchemy": {}
        },
        test: {
          name: "admin",
          environment: "jsdom",
          globals: true,
          root: "spec/javascript/alchemy_admin/",
          setupFiles: ["setup.js"]
        }
      },
      {
        // The preview bundle runs in the frontend, where none of the globals
        // the admin setup file defines exist.
        resolve,
        test: {
          name: "preview",
          environment: "jsdom",
          globals: true,
          root: "spec/javascript/",
          include: ["preview.spec.js"]
        }
      }
    ]
  }
})
