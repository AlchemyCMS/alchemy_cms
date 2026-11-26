# @alchemy_cms/preview

Element preview for frontends shown in the [AlchemyCMS](https://alchemy-cms.com) admin's preview frame.

Editors hovering an element in the preview see it outlined, clicking it opens its editor in the admin, and focusing an element editor in the admin scrolls to and highlights the element in the preview. Rails frontends get this from the `alchemy_cms` gem; this package brings it to headless frontends, e.g. ones fed by [alchemy-json_api](https://github.com/AlchemyCMS/alchemy-json_api).

Works with AlchemyCMS 8.4 and newer.

## Installation

```sh
npm install @alchemy_cms/preview
```

Configure the URL of your frontend as `preview.host` in the Alchemy config, so the admin loads it in the preview frame. Alchemy adds `alchemy_preview_mode=true` (and `alchemy_preview_time` if a preview time is selected) to that URL.

Every element needs a `data-alchemy-element` attribute with its id. Only render it in preview mode (see below), so public pages do not carry element ids.

If your frontend has its own preview code (click handlers posting `Alchemy.focusElementEditor` to the admin), remove it. Otherwise one click sends a message for every nested element and the admin focuses the outermost one.

## Nuxt

```js
// nuxt.config.ts
export default defineNuxtConfig({
  modules: ["@alchemy_cms/preview/nuxt"],
  alchemyPreview: {
    adminOrigin: "https://admin.example.com"
  }
})
```

The admin origin can be overridden at runtime with `NUXT_PUBLIC_ALCHEMY_PREVIEW_ADMIN_ORIGIN`. If TypeScript does not know the `alchemyPreview` key yet, run `npx nuxi prepare` to regenerate Nuxt's types.

Render elements with the `AlchemyElement` component, e.g. in the loops of your page layouts and of elements with nested elements. It works like Vue's `<component :is>`, passes the element on as `element` prop and marks the rendered component's root element:

```vue
<AlchemyElement
  v-for="element in page.elements"
  :key="element.id"
  :is="components[element.name]"
  :element="element"
/>
```

Other attributes and slots are passed on to the component as well. Like `<component :is>`, `is` takes a component or the name of a globally registered component. Components registered locally in the parent cannot be resolved by name, so pass the component itself.

For elements rendered without `AlchemyElement`, use the globally registered `v-alchemy-element` directive. It takes the element or its id:

```vue
<template>
  <article v-alchemy-element="element">...</article>
</template>
```

On components both apply to the component's root element. Vue ignores them on components with multiple root elements.

Both only set the attribute in the browser after the page is rendered, so the server rendered HTML never contains element ids and hydration is unaffected.

The preview state is available as `useNuxtApp().$alchemyPreview` (`{ enabled, time }`). It is only enabled in the browser, and only if the page is shown in a frame, so visitors adding the query parameter themselves do not get it.

## Vue

```js
import { createApp } from "vue"
import { previewState } from "@alchemy_cms/preview"
import {
  AlchemyElement,
  createAlchemyElementDirective
} from "@alchemy_cms/preview/vue"

const state = previewState()
const app = createApp(App)

app.directive("alchemy-element", createAlchemyElementDirective(state))
app.component("AlchemyElement", AlchemyElement)
```

Start the preview in your root component:

```js
import { useAlchemyPreview } from "@alchemy_cms/preview/vue"

// in setup()
if (state.enabled) {
  useAlchemyPreview({ adminOrigin: "https://admin.example.com" })
}
```

## Plain JavaScript

```js
import { init, destroy, previewState } from "@alchemy_cms/preview"

if (previewState().enabled) {
  init({ adminOrigin: "https://admin.example.com" })
}
```

Elements added to the page after `init()` are picked up automatically. `destroy()` stops the preview again.

### React

```js
import { useEffect } from "react"
import { init, destroy, previewState } from "@alchemy_cms/preview"

function App() {
  useEffect(() => {
    if (!previewState().enabled) return

    init({ adminOrigin: "https://admin.example.com" })
    return destroy
  }, [])
}
```

## License

BSD-3-Clause
