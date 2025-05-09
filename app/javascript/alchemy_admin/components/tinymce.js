import "tinymce"
import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { currentLocale } from "alchemy_admin/i18n"

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
  }

  /**
   * disconnect intersection observer and remove Tinymce editor if the web components get destroyed
   */
  disconnected() {
    if (this.tinymceIntersectionObserver !== null) {
      this.tinymceIntersectionObserver.disconnect()
    }

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
      editors.forEach((editor) => {
        // mark the editor container as visible
        // without these correction the editor remains hidden
        // after a drag and drop action
        editor.show()

        // remove the spinner after the Tinymce initialized
        this.getElementsByTagName("alchemy-spinner")[0].remove()

        // event listener to mark the editor as dirty
        if (this.elementEditor) {
          editor.on("dirty", () => this.elementEditor.setDirty())
          editor.on("click", () => this.elementEditor.onClickElement(false))
        }
      })
    })
  }

  get configuration() {
    const customConfig = {}

    // read the attributes on the component and add them as custom configuration
    this.getAttributeNames().forEach((attributeName) => {
      if (!["class", "id", "is", "name", "style"].includes(attributeName)) {
        const config = this.getAttribute(attributeName)
        const key = attributeName.replaceAll("-", "_")

        try {
          customConfig[key] = JSON.parse(config)
        } catch (e) {
          // also string values as parameter
          customConfig[key] = config
        }
      }
    })

    const config = {
      ...Alchemy.TinymceDefaults,
      ...customConfig,
      language: currentLocale(),
      selector: `#${this.editorId}`
    }

    // Tinymce has a height of 400px by default
    // if the element has a min_height set, we use this value for the height as well
    // so we do not need to set both values in the element configuration
    config.height = config.min_height

    return config
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
