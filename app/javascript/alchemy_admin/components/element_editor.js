import { post } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"

import "alchemy_admin/components/element_editor/publish_element_button"
import "alchemy_admin/components/element_editor/delete_element_button"

export class ElementEditor extends HTMLElement {
  #form = null
  #header = null
  #toggleButton = null

  connectedCallback() {
    // The placeholder while be being dragged is empty.
    if (this.classList.contains("ui-sortable-placeholder")) {
      return
    }

    // Add event listeners
    this.addEventListener("click", this)
    // Triggered by child elements
    this.addEventListener("alchemy:element-update-title", this)

    this.#form = this.form
    if (this.#form) {
      this.#form.addEventListener("change", this.onChange)
      this.#form.addEventListener("turbo:submit-start", this)
      this.#form.addEventListener("turbo:submit-end", this)
    }

    this.#header = this.header
    this.#header?.addEventListener("dblclick", this.#onHeaderDblclick)

    this.#toggleButton = this.toggleButton
    this.#toggleButton?.addEventListener("click", this.#onToggleClick)

    // When newly created, focus the element and refresh the preview
    if (this.hasAttribute("created")) {
      this.focusElement()
      this.previewWindow?.refresh().then(() => {
        this.focusElementPreview()
      })
      this.removeAttribute("created")
    }
  }

  disconnectedCallback() {
    this.removeEventListener("click", this)
    this.removeEventListener("alchemy:element-update-title", this)
    if (this.#form) {
      this.#form.removeEventListener("change", this.onChange)
      this.#form.removeEventListener("turbo:submit-start", this)
      this.#form.removeEventListener("turbo:submit-end", this)
      this.#form = null
    }
    this.#header?.removeEventListener("dblclick", this.#onHeaderDblclick)
    this.#header = null
    this.#toggleButton?.removeEventListener("click", this.#onToggleClick)
    this.#toggleButton = null
  }

  handleEvent(event) {
    switch (event.type) {
      case "click":
        const elementEditor = event.target.closest("alchemy-element-editor")
        if (elementEditor === this) {
          this.onClickElement()
        }
        break
      case "turbo:submit-start":
        this.setClean()
        break
      case "turbo:submit-end":
        this.onSaveElement(event.detail.success)
        break
      case "alchemy:element-update-title":
        if (!this.hasEditors && event.target == this.firstChild) {
          this.setTitle(event.detail.title)
        }
        break
    }
  }

  onChange = (event) => {
    const target = event.target
    // SortableJS fires a native change event :/
    // and we do not want to set the element editor dirty
    // when this happens
    if (target.classList.contains("nested-elements")) {
      return
    }
    this.setDirty(target)
    event.stopPropagation()
    return false
  }

  /**
   * Scrolls to and highlights element
   * Expands if collapsed
   * Also chooses the right fixed elements tab, if necessary.
   * Can be triggered through custom event 'FocusElementEditor.Alchemy'
   * Used by the elements on click events in the preview frame.
   */
  async focusElement() {
    // Select tab if necessary
    if (document.querySelector("#fixed-elements")) {
      await this.selectTabForElement()
    }
    // Expand if necessary
    await this.expand()
    this.selectElement(true)
  }

  focusElementPreview() {
    this.previewWindow?.postMessage({
      message: "Alchemy.focusElement",
      element_id: this.elementId
    })
  }

  onClickElement() {
    this.selectElement()
    this.focusElementPreview()
  }

  /**
   * Applies the client-side effects of a save once the turbo stream rendered.
   *
   * The notice, error markup, header title, anchor icons and publish button are
   * server-rendered turbo streams. Only the preview refresh (which must focus
   * this element afterwards) and the error box toggle remain client-side.
   * @argument {boolean} success
   */
  onSaveElement(success) {
    if (success) {
      this.previewWindow?.refresh().then(() => {
        this.focusElementPreview()
      })
    } else {
      this.elementErrors.classList.remove("hidden")
    }
  }

  /**
   * Smoothly scrolls to element
   */
  scrollToElement() {
    // The timeout gives the browser some time to calculate the position
    // of nested elements correctly
    setTimeout(() => {
      this.scrollIntoView({
        behavior: "smooth"
      })
    }, 50)
  }

  /**
   * Highlight element and optionally scroll into view
   * @param {boolean} scroll smoothly scroll element into view. Default (false)
   */
  selectElement(scroll = false) {
    document
      .querySelectorAll("alchemy-element-editor.selected")
      .forEach((el) => {
        el.classList.remove("selected")
      })
    window.requestAnimationFrame(() => {
      this.classList.add("selected")
    })
    if (scroll) this.scrollToElement()
  }

  /**
   * Selects tab for given element
   * Resolves the promise if this is done.
   * @returns {Promise}
   */
  selectTabForElement() {
    return new Promise((resolve, reject) => {
      const tabs = document.querySelector("#fixed-elements")
      const panel = this.closest("sl-tab-panel")
      if (tabs && panel) {
        tabs.show(panel.getAttribute("name"))
        resolve()
      } else {
        reject(new Error("No tabs present"))
      }
    })
  }

  /**
   * Sets the element into clean (safed) state
   */
  setClean() {
    this.dirty = false
    window.onbeforeunload = null
    this.elementErrors.classList.add("hidden")

    if (this.hasEditors) {
      this.body.querySelectorAll(".ingredient-editor").forEach((el) => {
        el.classList.remove("dirty", "validation_failed")
        el.querySelectorAll("small.error").forEach((e) => e.remove())
      })
    }
  }

  /**
   * Sets the element into dirty (unsafed) state
   * @param {HTMLElement} editor
   */
  setDirty(editor) {
    if (this.hasEditors) {
      this.dirty = true

      if (!window.onbeforeunload) {
        window.onbeforeunload = (event) => event.preventDefault()
      }

      editor?.closest(".ingredient-editor")?.classList.add("dirty")
    }
  }

  /**
   * Sets the title quote
   * @param {string} title
   */
  setTitle(title) {
    const quote = this.querySelector(".element-header .preview_text_quote")
    // Fixed elements have no header, so there is no quote to update.
    if (quote) {
      quote.textContent = title
    }
  }

  /**
   * Expands or collapses element editor
   * If the element is dirty (has unsaved changes) it displays a confirm first.
   */
  async toggle() {
    if (this.collapsed) {
      await this.expand()
    } else {
      await this.collapse()
    }
  }

  /**
   * Collapses the element editor and persists the state on the server
   * @returns {Promise}
   */
  collapse() {
    if (this.collapsed || this.compact || this.fixed) {
      return Promise.resolve("Element is already collapsed.")
    }

    const spinner = new Alchemy.Spinner("small")
    spinner.spin(this.toggleButton)
    this.toggleIcon?.classList?.add("hidden")
    return post(Alchemy.routes.collapse_admin_element_path(this.elementId))
      .then((response) => {
        const data = response.data

        this.collapsed = true
        this.toggleButton?.setAttribute("title", data.title)

        // Collapse all nested elements if necessarry
        if (data.nestedElementIds.length) {
          const selector = data.nestedElementIds
            .map((id) => `#element_${id}`)
            .join(", ")
          this.querySelectorAll(selector).forEach((nestedElement) => {
            nestedElement.collapsed = true
            nestedElement.toggleButton?.setAttribute("title", data.title)
          })
        }
      })
      .catch((error) => {
        growl(error.message, "error")
        console.error(error)
      })
      .finally(() => {
        this.toggleIcon?.classList?.remove("hidden")
        spinner.stop()
      })
  }

  /**
   * Collapses the element editor and persists the state on the server
   * @* @returns {Promise}
   */
  expand() {
    if (this.expanded && !this.compact) {
      return Promise.resolve("Element is already expanded.")
    }

    if (this.compact && this.parentElementEditor) {
      return this.parentElementEditor.expand()
    } else {
      const spinner = new Alchemy.Spinner("small")
      spinner.spin(this.toggleButton)
      this.toggleIcon?.classList.add("hidden")

      return new Promise((resolve, reject) => {
        post(Alchemy.routes.expand_admin_element_path(this.elementId))
          .then((response) => {
            const data = response.data

            // First expand all parent elements if necessary
            if (data.parentElementIds.length) {
              const selector = data.parentElementIds
                .map((id) => `#element_${id}`)
                .join(", ")
              document.querySelectorAll(selector).forEach((parentElement) => {
                parentElement.collapsed = false
                parentElement.toggleButton?.setAttribute("title", data.title)
              })
            }
            // Finally expand ourselve
            this.collapsed = false
            this.toggleButton?.setAttribute("title", data.title)
            // Resolve the promise that scrolls to the element very last
            resolve()
          })
          .catch((error) => {
            growl(error.message, "error")
            console.error(error)
            reject(error)
          })
          .finally(() => {
            this.toggleIcon?.classList?.remove("hidden")
            spinner.stop()
          })
      })
    }
  }

  /**
   * Updates the quote in the element header and dispatches event
   * to parent elements
   * @param {string} title
   */
  updateTitle(title) {
    this.setTitle(title)
    this.dispatchEvent(
      new CustomEvent("alchemy:element-update-title", {
        bubbles: true,
        detail: { title }
      })
    )
  }

  /**
   * Sets element published or hidden
   * @param {boolean}
   */
  set published(isPublished) {
    if (isPublished) {
      this.classList.remove("element-hidden")
    } else {
      this.classList.add("element-hidden")
    }
  }

  /**
   * Is element published or hidden
   * @returns {boolean}
   */
  get published() {
    return !this.classList.contains("hidden")
  }

  /**
   * @returns {boolean}
   */
  get compact() {
    return this.getAttribute("compact") !== null
  }

  /**
   * @returns {boolean}
   */
  get fixed() {
    return this.getAttribute("fixed") !== null
  }

  /**
   * @param {boolean} value
   */
  set collapsed(value) {
    this.classList.toggle("folded", value)
    this.classList.toggle("expanded", !value)
    this.toggleIcon &&
      (this.toggleIcon.name = value ? "arrow-left-s" : "arrow-down-s")
  }

  /**
   * @returns {boolean}
   */
  get collapsed() {
    return this.classList.contains("folded")
  }

  /**
   * @returns {boolean}
   */
  get expanded() {
    return !this.collapsed
  }

  /**
   * Toggles the dirty class
   *
   * @param {boolean} value
   */
  set dirty(value) {
    this.classList.toggle("dirty", value)
  }

  /**
   * Returns the dirty state of this element
   *
   * @returns {boolean}
   */
  get dirty() {
    return this.classList.contains("dirty")
  }

  /**
   * Returns the element header
   *
   * @returns {HTMLElement|undefined}
   */
  get header() {
    return this.querySelector(`.element-header`)
  }

  /**
   * Returns the immediate body container of this element if present
   *
   * Makes sure it does not return a nested elements body
   * by scoping the selector to this elements id.
   *
   * @returns {HTMLElement|undefined}
   */
  get body() {
    return this.querySelector(this.bodySelector)
  }

  get bodySelector() {
    return `#${this.id} > .element-body`
  }

  /**
   * Returns the immediate footer container of this element if present
   *
   * Makes sure it does not return a nested elements footer
   * by scoping the selector to this elements id.
   *
   * @returns {HTMLElement|undefined}
   */
  get footer() {
    return this.querySelector(`#${this.id} > .element-footer`)
  }

  /**
   * The collapse/expand toggle button
   *
   * @returns {HTMLButtonElement|undefined}
   */
  get toggleButton() {
    return this.querySelector(".element-toggle")
  }

  /**
   * The collapse/expand toggle buttons icon
   *
   * @returns {HTMLElement|undefined}
   */
  get toggleIcon() {
    return this.toggleButton?.querySelector("alchemy-icon")
  }

  /**
   * The validation messages list container
   *
   * @returns {HTMLElement}
   */
  get elementErrors() {
    return this.body.querySelector(".element_errors")
  }

  /**
   * The element database id
   *
   * @returns {string}
   */
  get elementId() {
    return this.dataset.elementId
  }

  /**
   * The element defintion name
   *
   * @returns {string}
   */
  get elementName() {
    return this.dataset.elementName
  }

  /**
   * Does this element have ingredient editor fields?
   *
   * @returns {boolean}
   */
  get hasEditors() {
    return !!this.body?.querySelector(".element-ingredient-editors")
  }

  /**
   * Does this element have nested elements?
   *
   * @returns {boolean}
   */
  get hasChildren() {
    return !!this.querySelector(".nested-elements")
  }

  /**
   * The first child element editor if present
   *
   * @returns {HTMLButtonElement|undefined}
   */
  get firstChild() {
    return this.querySelector("alchemy-element-editor")
  }

  /**
   * The form element if present
   *
   * @returns {HTMLFormElement|undefined}
   */
  get form() {
    return this.querySelector("form.element-body")
  }

  /**
   * The parent element editor if present
   *
   * @returns {ElementEditor|undefined}
   */
  get parentElementEditor() {
    return this.parentElement?.closest("alchemy-element-editor")
  }

  get previewWindow() {
    return document.getElementById("alchemy_preview_window")
  }

  #onHeaderDblclick = () => {
    this.toggle()
  }

  #onToggleClick = (evt) => {
    const elementEditor = evt.target.closest("alchemy-element-editor")
    if (elementEditor === this) {
      this.toggle()
    }
  }
}

customElements.define("alchemy-element-editor", ElementEditor)
