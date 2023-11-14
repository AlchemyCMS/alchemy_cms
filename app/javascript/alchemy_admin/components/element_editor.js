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
    this.addEventListener("FocusElementEditor.Alchemy", (event) => {
      event.stopPropagation()
      this.focusElement()
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

    if (sessionStorage.hasOwnProperty("Alchemy.expanded_ingredient_groups")) {
      this.expandIngredientGroups()
    }
  }

  /**
   * Expands ingredient groups that are stored in sessionStorage as expanded
   */
  expandIngredientGroups() {
    const expanded_ingredient_groups = sessionStorage.getItem(
      "Alchemy.expanded_ingredient_groups"
    )
    Array.from(JSON.parse(expanded_ingredient_groups)).forEach((header_id) => {
      const header = document.querySelector(`#${header_id}`)
      const group = header?.closest(".ingredient-group")
      group?.classList.add("expanded")
    })
  }

  /**
   * Scrolls to element
   * Unfold if folded
   * Also chooses the right fixed elements tab, if necessary.
   * Can be triggered through custom event 'FocusElementEditor.Alchemy'
   * Used by the elements on click events in the preview frame.
   */
  focusElement() {
    const focus = () => {
      // If we have folded parents we need to unfold each of them
      // and then finally scroll to or unfold ourself
      const foldedParents = parents(this, "alchemy-element-editor.folded")
      if (foldedParents.length > 0) {
        this.unfoldParents(foldedParents, () => {
          this.scrollToOrUnfold()
        })
      } else {
        this.scrollToOrUnfold(() => this.selectElement(true))
      }
    }
    const tabs = document.querySelector("#fixed-elements")
    if (tabs) {
      this.selectTabForElement(focus)
    } else {
      focus()
    }
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
      sessionStorage.getItem("Alchemy.expanded_ingredient_groups") || "[]"
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

    sessionStorage.setItem(
      "Alchemy.expanded_ingredient_groups",
      JSON.stringify(expanded_ingredient_groups)
    )
  }

  /**
   * Smoothly scrolls to element
   */
  scrollToElement() {
    this.scrollIntoView({
      behavior: "smooth"
    })
  }

  /**
   * Scrolls to element
   * If it's folded it unfolds it.
   *
   * Also takes an optional callback that gets triggered after element is unfolded.
   */
  scrollToOrUnfold(callback) {
    if (this.classList.contains("folded")) {
      this.toggleFold(callback)
    } else {
      this.selectElement(true)
    }
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
   * Takes an optional callback that gets called after the tab panel is shown.
   * @param {function} callback
   */
  selectTabForElement(callback) {
    const tabs = document.querySelector("#fixed-elements")
    const panel = this.closest("sl-tab-panel")
    if (tabs && panel) {
      tabs.show(panel.getAttribute("name"))
      if (callback) {
        window.requestAnimationFrame(callback)
      }
    }
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
  toggle() {
    if (this.dirty) {
      Alchemy.openConfirmDialog(Alchemy.t("element_dirty_notice"), {
        title: Alchemy.t("warning"),
        ok_label: Alchemy.t("ok"),
        cancel_label: Alchemy.t("cancel"),
        on_ok: () => this.toggleFold()
      })
    } else {
      this.toggleFold()
    }
  }

  /**
   * Collapses or expands the element editor and persists the state on the server
   * @param {function} callback
   */
  toggleFold(callback) {
    const spinner = new Alchemy.Spinner("small")
    spinner.spin(this.toggleButton)
    this.toggleIcon.classList.add("hidden")
    return post(Alchemy.routes.fold_admin_element_path(this.elementId))
      .then((response) => {
        const data = response.data
        this.folded = data.folded
        this.classList.toggle("folded")
        this.classList.toggle("expanded")
        this.toggleIcon.classList.toggle("fa-minus-square")
        this.toggleIcon.classList.toggle("fa-plus-square")
        this.toggleButton.setAttribute("title", data.title)
        callback?.call()
      })
      .catch((error) => {
        Alchemy.growl(error.message, "error")
      })
      .finally(() => {
        this.toggleIcon.classList.remove("hidden")
        spinner.stop()
      })
  }

  /**
   * Unfolds given parents until the last one is reached, then calls callback
   * @param {array} foldedParents
   * @param {function} callback (optional)
   */
  unfoldParents(foldedParents, callback) {
    const lastParent = foldedParents[foldedParents.length - 1]
    foldedParents.forEach((parentElement) => {
      if (lastParent === parentElement) {
        parentElement.toggleFold(callback)
      } else {
        parentElement.toggleFold()
      }
    })
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
   * @returns {HTMLButtonElement}
   */
  get toggleButton() {
    return this.querySelector(".element-toggle")
  }

  /**
   * The collapse/expand toggle buttons icon
   *
   * @returns {HTMLElement}
   */
  get toggleIcon() {
    return this.toggleButton.querySelector(".icon")
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
}

customElements.define("alchemy-element-editor", ElementEditor)
