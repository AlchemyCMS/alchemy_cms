const ELEMENT_SELECTOR = "[data-alchemy-element]"

const STYLES = {
  reset: {
    outline: "",
    "outline-offset": "",
    cursor: ""
  },
  hover: {
    outline: "2px dashed #f0b437",
    "outline-offset": "4px",
    cursor: "pointer"
  },
  selected: {
    outline: "2px dashed #90b9d0",
    "outline-offset": "4px"
  }
}

let adminOrigin = null
let selection = null

function allElements() {
  return Array.from(document.querySelectorAll(ELEMENT_SELECTOR))
}

// Calls the callback for the element containing the target and every element
// it is nested in.
function eachElement(target, callback) {
  let element = target.closest(ELEMENT_SELECTOR)

  while (element) {
    callback(element)
    element = element.parentElement?.closest(ELEMENT_SELECTOR)
  }
}

// Mark element in preview frame as selected and scrolls to it.
function selectElement(element) {
  blurElements(element)
  selection = element
  Object.assign(element.style, STYLES.selected)
  element.scrollIntoView({
    behavior: "smooth",
    block: "start"
  })
}

// Blur all elements in preview frame.
function blurElements(selectedElement) {
  allElements().forEach((element) => {
    if (element !== selectedElement) {
      Object.assign(element.style, STYLES.reset)
    }
  })
  selection = null
}

function getElement(elementId) {
  return allElements().find(
    (element) => element.dataset.alchemyElement === elementId.toString()
  )
}

// Focus the element in the Alchemy preview window.
function focusElement(data) {
  const element = getElement(data.element_id)

  if (element) {
    selectElement(element)
  } else {
    console.warn("Could not focus element with id", data.element_id)
  }
}

function framed() {
  return window.self !== window.top
}

function postToAdmin(data) {
  window.parent.postMessage(data, adminOrigin)
}

// Focus the element editor in the Alchemy element window.
function focusElementEditor(element) {
  postToAdmin({
    message: "Alchemy.focusElementEditor",
    element_id: element.dataset.alchemyElement
  })
}

function onMouseOver(event) {
  eachElement(event.target, (element) => {
    if (element !== selection) {
      Object.assign(element.style, STYLES.hover)
    }
  })
}

function onMouseOut(event) {
  eachElement(event.target, (element) => {
    if (element !== selection) {
      Object.assign(element.style, STYLES.reset)
    }
  })
}

function selectClickedElement(event) {
  const element = event.target.closest(ELEMENT_SELECTOR)

  if (element) {
    selectElement(element)
    focusElementEditor(element)
  }

  return element
}

function navigates(target) {
  if (target.closest("a")) return true

  const control = target.closest("button, input")
  return Boolean(control?.form) && ["submit", "image"].includes(control.type)
}

// Client side routers navigate from click handlers on the link itself, so
// navigating clicks have to be taken before the event reaches the page.
function onNavigatingClick(event) {
  if (navigates(event.target) && selectClickedElement(event)) {
    event.stopPropagation()
    event.preventDefault()
  }
}

function onMessage(event) {
  if (event.origin !== adminOrigin) return

  switch (event.data.message) {
    case "Alchemy.blurElements":
      blurElements()
      break
    case "Alchemy.focusElement":
      focusElement(event.data)
      break
    default:
      console.info("Received unknown message!", event.data)
  }
}

/**
 * Starts the preview: outlines elements on hover, selects them on click and
 * talks to the Alchemy admin the page is framed in. Does nothing outside of a
 * frame.
 *
 * @param {Object} [options]
 * @param {string} [options.adminOrigin] Origin of the Alchemy admin. Messages
 *   are only sent to and accepted from it. Defaults to the page's own origin.
 */
export function init(options = {}) {
  if (adminOrigin || !framed()) return

  adminOrigin = options.adminOrigin || window.location.origin

  window.addEventListener("message", onMessage)
  window.addEventListener("click", onNavigatingClick, { capture: true })
  window.addEventListener("click", selectClickedElement)
  document.addEventListener("mouseover", onMouseOver)
  document.addEventListener("mouseout", onMouseOut)

  // Notify parent window that preview is ready
  postToAdmin({ message: "Alchemy.previewReady" })
}

/**
 * Stops the preview and removes all outlines.
 */
export function destroy() {
  if (!adminOrigin) return

  window.removeEventListener("message", onMessage)
  window.removeEventListener("click", onNavigatingClick, { capture: true })
  window.removeEventListener("click", selectClickedElement)
  document.removeEventListener("mouseover", onMouseOver)
  document.removeEventListener("mouseout", onMouseOut)

  blurElements()
  adminOrigin = null
}

/**
 * Reads the preview state from the current URL.
 *
 * The preview is only enabled when the page is framed (by the Alchemy admin),
 * so visitors adding the query parameter themselves do not get it.
 *
 * @returns {{ enabled: boolean, time: string | null }}
 */
export function previewState() {
  if (typeof window === "undefined") return { enabled: false, time: null }

  const params = new URLSearchParams(window.location.search)

  return {
    enabled: params.get("alchemy_preview_mode") === "true" && framed(),
    time: params.get("alchemy_preview_time")
  }
}
