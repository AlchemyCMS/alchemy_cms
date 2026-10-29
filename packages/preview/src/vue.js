import { onMounted, onUnmounted } from "vue"
import { init, destroy } from "./index.js"

function setElementId(el, { value }) {
  const id = typeof value === "object" ? value?.id : value

  if (id == null) {
    el.removeAttribute("data-alchemy-element")
  } else {
    el.setAttribute("data-alchemy-element", id)
  }
}

/**
 * Creates the `v-alchemy-element` directive, which marks an element (or a
 * component's root element) as the given Alchemy element. It takes the
 * element itself or its id.
 *
 * Outside of preview mode it does nothing, so public pages carry no element
 * ids.
 *
 * @param {{ enabled: boolean }} state The preview state, see `previewState()`
 */
export function createAlchemyElementDirective(state) {
  return state.enabled ? { mounted: setElementId, updated: setElementId } : {}
}

/**
 * Starts the preview when the calling component mounts and stops it when it
 * unmounts. Meant to be used once in the app's root component.
 *
 * @param {Object} [options] Options passed to `init()`
 */
export function useAlchemyPreview(options) {
  onMounted(() => init(options))
  onUnmounted(destroy)
}
