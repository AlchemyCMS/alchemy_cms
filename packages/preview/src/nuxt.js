import { addPlugin, createResolver, defineNuxtModule } from "nuxt/kit"

export default defineNuxtModule({
  meta: {
    name: "@alchemy_cms/preview",
    configKey: "alchemyPreview",
    compatibility: { nuxt: ">=3.3.0" }
  },
  defaults: {
    adminOrigin: ""
  },
  setup(options, nuxt) {
    const { resolve } = createResolver(import.meta.url)

    nuxt.options.runtimeConfig.public.alchemyPreview = {
      adminOrigin: options.adminOrigin,
      ...nuxt.options.runtimeConfig.public.alchemyPreview
    }
    // The plugin imports from #app, which only resolves if Nuxt bundles it
    // instead of loading it from node_modules on the server.
    nuxt.options.build.transpile.push(resolve("."))
    addPlugin(resolve("./nuxt-plugin.js"))

    nuxt.hook("prepare:types", ({ references }) => {
      references.push({ path: resolve("../types/nuxt.d.ts") })
    })
  }
})
