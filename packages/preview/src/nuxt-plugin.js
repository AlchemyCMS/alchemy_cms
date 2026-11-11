import { defineNuxtPlugin, useRuntimeConfig } from "#app"
import { init, previewState } from "./index.js"
import { AlchemyElement, createAlchemyElementDirective } from "./vue.js"

export default defineNuxtPlugin((nuxtApp) => {
  const state = previewState()

  nuxtApp.vueApp.directive(
    "alchemy-element",
    createAlchemyElementDirective(state)
  )
  nuxtApp.vueApp.component("AlchemyElement", AlchemyElement)

  if (state.enabled) {
    const { adminOrigin } = useRuntimeConfig().public.alchemyPreview
    nuxtApp.hook("app:mounted", () => init({ adminOrigin }))
  }

  return {
    provide: {
      alchemyPreview: state
    }
  }
})
