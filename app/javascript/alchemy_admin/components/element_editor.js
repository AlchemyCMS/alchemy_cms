import TagsAutocomplete from "alchemy_admin/tags_autocomplete"
import ImageLoader from "alchemy_admin/image_loader"
import fileEditors from "alchemy_admin/file_editors"
import pictureEditors from "alchemy_admin/picture_editors"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import { on } from "alchemy_admin/utils/events"
import { post } from "alchemy_admin/utils/ajax"
import { createHtmlElement } from "../utils/dom_helpers"

export class ElementEditor extends HTMLElement {
  connectedCallback() {
    const self = this

    // The placeholder while be being dragged is empty.
    if (this.classList.contains("ui-sortable-placeholder")) {
      return
    }

    // Init GUI elements
    ImageLoader.init(this)
    fileEditors(
      `#${this.id} .ingredient-editor.file, #${this.id} .ingredient-editor.audio, #${this.id} .ingredient-editor.video`
    )
    pictureEditors(`#${this.id} .ingredient-editor.picture`)
    TagsAutocomplete(this)

    // Add event listeners
    this.addEventListener("click", (evt) => {
      const elementEditor = evt.target.closest("alchemy-element-editor")
      if (elementEditor === this) {
        this.onClickElement()
      }
    })
    this.header?.addEventListener("dblclick", () => {
      this.toggle()
    })
    this.toggleButton?.addEventListener("click", (evt) => {
      const elementEditor = evt.target.closest("alchemy-element-editor")
      if (elementEditor === this) {
        this.toggle()
      }
    })
    on(
      "click",
      this.bodySelector,
      "[data-toggle-ingredient-group]",
      function (event) {
        self.onToggleIngredientGroup(this)
        event.preventDefault()
      }
    )

    if (this.hasChildren) {
      this.addEventListener("alchemy:element-update-title", (event) => {
        if (event.target == this.firstChild) {
          this.setTitle(event.detail.title)
        }
      })
      this.addEventListener("alchemy:element-dirty", (event) => {
        if (event.target !== this) {
          this.setDirty()
        }
      })
      this.addEventListener("alchemy:element-clean", (event) => {
        if (event.target !== this) {
          this.setClean()
        }
      })
    }

    if (this.body) {
      // We use of @rails/ujs for Rails remote forms
      this.body.addEventListener("ajax:success", (event) => {
        const responseJSON = event.detail[0]
        event.stopPropagation()
        this.onSaveElement(responseJSON)
      })
      // Dirty observer
      on("change", this.bodySelector, "input, select", (event) => {
        const content = event.target
        event.stopPropagation()
        content.classList.add("dirty")
        this.setDirty()
      })
    }

    if (localStorage.hasOwnProperty("Alchemy.expanded_ingredient_groups")) {
      this.expandIngredientGroups()
    }
  }

  /**
   * Expands ingredient groups that are stored in localStorage as expanded
   */
  expandIngredientGroups() {
    const expanded_ingredient_groups = localStorage.getItem(
      "Alchemy.expanded_ingredient_groups"
    )
    Array.from(JSON.parse(expanded_ingredient_groups)).forEach((header_id) => {
      const header = document.querySelector(`#${header_id}`)
      const group = header?.closest(".ingredient-group")
      group?.classList.add("expanded")
    })
  }

  /**
   * Scrolls and highlights element
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
    Alchemy.PreviewWindow.postMessage({
      message: "Alchemy.focusElement",
      element_id: this.elementId
    })
  }

  onClickElement() {
    this.selectElement()
    this.focusElementPreview()
  }

  /**
   * Sets the element to saved state
   * Updates title
   * Shows error messages if ingredient validations fail
   * @argument {JSON} data
   */
  onSaveElement(data) {
    // JS event bubbling will also update the parents element quote.
    this.setClean()
    // Reset errors that might be visible from last save attempt
    this.errorsDisplay.innerHTML = ""
    this.body
      .querySelectorAll(".ingredient-editor")
      .forEach((el) => el.classList.remove("validation_failed"))
    // If validation failed
    if (data.errors) {
      const warning = data.warning
      // Create error messages
      data.errors.forEach((message) => {
        this.errorsDisplay.append(createHtmlElement(`<li>${message}</li>`))
      })
      // Mark ingredients as failed
      data.ingredientsWithErrors.forEach((id) => {
        this.querySelector(`[data-ingredient-id="${id}"]`)?.classList.add(
          "validation_failed"
        )
      })
      // Show message
      Alchemy.growl(warning, "warn")
      this.elementErrors.classList.remove("hidden")
    } else {
      Alchemy.growl(data.notice)
      Alchemy.PreviewWindow.refresh(() => this.focusElementPreview())
      this.updateTitle(data.previewText)
      data.ingredientAnchors.forEach((anchor) => {
        IngredientAnchorLink.updateIcon(anchor.ingredientId, anchor.active)
      })
    }
  }

  /**
   * Toggle visibility of the ingredient fields in the group
   * @param {HTMLLinkElement} target
   */
  onToggleIngredientGroup(target) {
    const group_div = target.closest(".ingredient-group")
    group_div.classList.toggle("expanded")

    let expanded_ingredient_groups = JSON.parse(
      localStorage.getItem("Alchemy.expanded_ingredient_groups") || "[]"
    )

    // Add or remove depending on whether this ingredient group is expanded
    if (group_div.classList.contains("expanded")) {
      if (expanded_ingredient_groups.indexOf(target.id) === -1) {
        expanded_ingredient_groups.push(target.id)
      }
    } else {
      expanded_ingredient_groups = expanded_ingredient_groups.filter(
        (value) => value !== target.id
      )
    }

    localStorage.setItem(
      "Alchemy.expanded_ingredient_groups",
      JSON.stringify(expanded_ingredient_groups)
    )
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
    document.querySelectorAll("alchemy-element-editor").forEach((el) => {
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
   * Dispatches alchemy:element-clean event
   */
  setClean() {
    this.dirty = false
    window.onbeforeunload = () => {}
    this.dispatchEvent(
      new CustomEvent("alchemy:element-clean", { bubbles: true })
    )
    if (this.hasEditors) {
      this.body.querySelectorAll(".dirty").forEach((el) => {
        el.classList.remove("dirty")
      })
    }
  }

  /**
   * Sets the element into dirty (unsafed) state
   * Dispatches alchemy:element-dirty event
   */
  setDirty() {
    this.dirty = true
    this.dispatchEvent(
      new CustomEvent("alchemy:element-dirty", { bubbles: true })
    )
    window.onbeforeunload = () => Alchemy.t("page_dirty_notice")
  }

  /**
   * Sets the title quote
   * @param {string} title
   */
  setTitle(title) {
    const quote = this.querySelector(".element-header .preview_text_quote")
    quote.textContent = title
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
      return Promise.resolve()
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
            .map((e) => `#element_${e.id}`)
            .join(", ")
          this.querySelectorAll(selector).forEach((nestedElement) => {
            nestedElement.collapsed = true
            nestedElement.toggleButton?.setAttribute("title", data.title)
          })
        }
      })
      .catch((error) => {
        Alchemy.growl(error.message, "error")
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
      return Promise.resolve()
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
            // Finally collapse ourselve
            this.collapsed = false
            this.toggleButton?.setAttribute("title", data.title)
            // Resolve the promise that scrolls to the element very last
            resolve()
          })
          .catch((error) => {
            Alchemy.growl(error.message, "error")
            console.error(error)
            reject()
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
   * @returns {boolean}
   */
  get compact() {
    return !!this.getAttribute("compact")
  }

  /**
   * @returns {boolean}
   */
  get fixed() {
    return !!this.getAttribute("fixed")
  }

  /**
   * @param {boolean} value
   */
  set collapsed(value) {
    this.classList.toggle("folded", value)
    this.classList.toggle("expanded", !value)
    this.toggleIcon?.classList?.toggle("fa-minus-square", !value)
    this.toggleIcon?.classList?.toggle("fa-plus-square", value)
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
    return this.toggleButton?.querySelector(".icon")
  }

  /**
   * The error messages container
   *
   * @returns {HTMLElement}
   */
  get errorsDisplay() {
    return this.body.querySelector(".error-messages")
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
   * The parent element editor if present
   *
   * @returns {ElementEditor|undefined}
   */
  get parentElementEditor() {
    return this.parentElement?.closest("alchemy-element-editor")
  }
}

customElements.define("alchemy-element-editor", ElementEditor)
