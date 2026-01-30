import "tinymce"
import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { currentLocale } from "alchemy_admin/i18n"

const DARK_THEME = "alchemy-dark"
const LIGHT_THEME = "alchemy"

class Tinymce extends AlchemyHTMLElement {
  #min_height = null

  /**
   * the observer will initialize Tinymce if the textarea becomes visible
   */
  connected() {
    this.className = "tinymce_container"

    const observerCallback = (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.intersectionRatio > 0) {
          this._initTinymceEditor()
          // disable observer after the Tinymce was initialized
          observer.unobserve(entry.target)
        }
      })
    }

    const options = {
      root: document.getElementById("element_area"),
      rootMargin: "0px",
      threshold: [0.05]
    }

    this.tinymceIntersectionObserver = new IntersectionObserver(
      observerCallback,
      options
    )
    this.tinymceIntersectionObserver.observe(this)

    // Set up theme change listener
    this._setupThemeChangeListener()
  }

  /**
   * disconnect intersection observer and remove Tinymce editor if the web components get destroyed
   */
  disconnected() {
    if (this.tinymceIntersectionObserver !== null) {
      this.tinymceIntersectionObserver.disconnect()
    }

    // Remove theme change listener
    this._removeThemeChangeListener()

    tinymce.get(this.editorId)?.remove(this.editorId)
  }

  render() {
    return `
      ${this.initialContent}
      <alchemy-spinner size="small"></alchemy-spinner>
    `
  }

  /**
   * hide the textarea until TinyMCE is ready to show the editor
   */
  afterRender() {
    this.style.minHeight = `${this.minHeight}px`
    this.editor.style.display = "none"
  }

  /**
   * initialize Richtext area after the Intersection observer triggered
   * @private
   */
  _initTinymceEditor() {
    tinymce.init(this.configuration).then((editors) => {
      editors.forEach((editor) => this._setupEditor(editor))
    })
  }

  /**
   * Setup editor after initialization
   * @param {Object} editor - The TinyMCE editor instance
   * @private
   */
  _setupEditor(editor) {
    // mark the editor container as visible
    // without these correction the editor remains hidden
    // after a drag and drop action
    editor.show()

    // remove the spinner after the Tinymce initialized (only on first init)
    const spinner = this.getElementsByTagName("alchemy-spinner")[0]
    if (spinner) {
      spinner.remove()
    }

    // event listener to mark the editor as dirty
    if (this.elementEditor) {
      editor.on("dirty", (evt) => {
        this.elementEditor.setDirty(evt.target.editorContainer)
      })
      editor.on("click", () => this.elementEditor.onClickElement(false))
    }
  }

  /**
   * Set up listener for OS theme changes
   * @private
   */
  _setupThemeChangeListener() {
    this.darkModeMediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.themeChangeHandler = (event) => this._handleThemeChange(event)
    this.darkModeMediaQuery.addEventListener("change", this.themeChangeHandler)
  }

  /**
   * Remove theme change listener
   * @private
   */
  _removeThemeChangeListener() {
    if (this.darkModeMediaQuery && this.themeChangeHandler) {
      this.darkModeMediaQuery.removeEventListener(
        "change",
        this.themeChangeHandler
      )
    }
  }

  /**
   * Handle OS theme change and update TinyMCE skin
   * @param {MediaQueryListEvent} event - The media query change event
   * @private
   */
  _handleThemeChange(event) {
    const editor = tinymce.get(this.editorId)
    if (editor) {
      const skin = event.matches ? DARK_THEME : LIGHT_THEME
      const content_css = event.matches ? DARK_THEME : LIGHT_THEME

      // Update the skin by reinitializing the editor with new configuration
      editor.remove()
      tinymce
        .init({
          content_css,
          ...this.configuration,
          skin
        })
        .then((editors) => {
          editors.forEach((editor) => this._setupEditor(editor))
        })
    }
  }

  get configuration() {
    const customConfig = {}

    // read the attributes on the component and add them as custom configuration
    this.getAttributeNames().forEach((attributeName) => {
      if (!["class", "id", "is", "name", "style"].includes(attributeName)) {
        const config = this.getAttribute(attributeName)
        const key = attributeName.replaceAll("-", "_")

        // Handle boolean HTML attributes (e.g., readonly="readonly" or readonly="")
        if (config === attributeName || config === "") {
          customConfig[key] = true
        } else {
          try {
            customConfig[key] = JSON.parse(config)
          } catch (e) {
            // also string values as parameter
            customConfig[key] = config
          }
        }
      }
    })

    const config = {
      content_css: this.preferredTheme,
      ...Alchemy.TinymceDefaults,
      ...customConfig,
      language: currentLocale(),
      selector: `#${this.editorId}`,
      skin: this.preferredTheme
    }

    // Tinymce has a height of 400px by default
    // if the element has a min_height set, we use this value for the height as well
    // so we do not need to set both values in the element configuration
    config.height = config.min_height

    return config
  }

  get preferredTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches
      ? DARK_THEME
      : LIGHT_THEME
  }

  get editorId() {
    return this.editor.id
  }

  get editor() {
    return this.getElementsByTagName("textarea")[0]
  }

  get elementEditor() {
    return document
      .getElementById(this.editorId)
      .closest("alchemy-element-editor")
  }

  get minHeight() {
    return this.#min_height || this.configuration.min_height
  }

  set minHeight(value) {
    this.#min_height = value
  }
}

customElements.define("alchemy-tinymce", Tinymce)
