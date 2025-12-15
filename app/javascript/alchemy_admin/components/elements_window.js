import SortableElements from "alchemy_admin/sortable_elements"
import { ElementEditor } from "alchemy_admin/components/element_editor"

class ElementsWindow extends HTMLElement {
  #visible = true
  #turboFrame = null

  constructor() {
    super()
    this.#attachEvents()
  }

  connectedCallback() {
    this.toggleButton?.addEventListener("click", (evt) => {
      evt.preventDefault()
      this.toggle()
    })
    if (window.location.hash) {
      this.focusElementEditor(window.location.hash)
    }
    SortableElements()
    this.resize()
  }

  collapseAllElements() {
    this.querySelectorAll(
      "alchemy-element-editor:not([compact]):not([fixed])"
    ).forEach((editor) => editor.collapse())
  }

  toggle() {
    this.#visible ? this.hide() : this.show()
  }

  show() {
    document.body.classList.add("elements-window-visible")
    this.#visible = true
    this.toggleButton.closest("sl-tooltip").content = Alchemy.t("Hide elements")
    this.toggleButton
      .querySelector("alchemy-icon")
      .setAttribute("name", "menu-unfold")
    this.resize()
  }

  hide() {
    document.body.classList.remove("elements-window-visible")
    document.body.style.removeProperty("--elements-window-width")
    this.#visible = false
    this.toggleButton.closest("sl-tooltip").content = Alchemy.t("Show elements")
    this.toggleButton
      .querySelector("alchemy-icon")
      .setAttribute("name", "menu-fold")
  }

  resize(width) {
    if (width === undefined) {
      width = this.widthFromCookie
    }

    if (width) {
      document.body.style.setProperty("--elements-window-width", `${width}px`)
      document.cookie = `alchemy-elements-window-width=${width}; SameSite=Lax; Path=/;`
    }
  }

  // Focus element editor and element in preview if URL contains hash to element editor.
  // The link is coming from the assignment view when showing assigned files or pictures.
  focusElementEditor(dom_id) {
    const el = document.querySelector(dom_id)

    if (el instanceof ElementEditor) {
      el.focusElement() && el.focusElementPreview()
    }
  }

  get collapseButton() {
    return this.querySelector("#collapse-all-elements-button")
  }

  get toggleButton() {
    return document.querySelector("#element_window_button")
  }

  get previewWindow() {
    return document.getElementById("alchemy_preview_window")
  }

  get turboFrame() {
    if (!this.#turboFrame) {
      this.#turboFrame = this.closest("turbo-frame")
    }
    return this.#turboFrame
  }

  get widthFromCookie() {
    return document.cookie
      .split("; ")
      .find((row) => row.startsWith("alchemy-elements-window-width="))
      ?.split("=")[1]
  }

  set isDragged(dragged) {
    this.turboFrame.style.transitionProperty = dragged ? "none" : null
    this.turboFrame.style.pointerEvents = dragged ? "none" : null
  }

  #attachEvents() {
    this.collapseButton?.addEventListener("click", () => {
      this.collapseAllElements()
    })
    window.addEventListener("message", (event) => {
      const data = event.data
      if (data?.message == "Alchemy.focusElementEditor") {
        const element = document.getElementById(`element_${data.element_id}`)
        this.show()
        element?.focusElement()
      }
    })
    document.body.addEventListener("click", (evt) => {
      if (!evt.target.closest("alchemy-element-editor")) {
        this.querySelectorAll("alchemy-element-editor").forEach((editor) => {
          editor.classList.remove("selected")
        })
        this.previewWindow?.postMessage({ message: "Alchemy.blurElements" })
      }
    })
  }
}

customElements.define("alchemy-elements-window", ElementsWindow)
