import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { currentLocale } from "alchemy_admin/i18n"

const TOOLBAR_ROW_HEIGHT = 30
const TOOLBAR_BORDER_WIDTH = 1
const STATUSBAR_HEIGHT = 29.5
const EDITOR_BORDER_WIDTH = 2

class Tinymce extends AlchemyHTMLElement {
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
        editor.on("dirty", () => this.elementEditor.setDirty())
        editor.on("click", () => this.elementEditor.onClickElement(false))
      })
    })
  }

  get configuration() {
    const customConfig = {}

    // read the attributes on the component and add them as custom configuration
    this.getAttributeNames().forEach((attributeName) => {
      if (!["class", "id", "is", "name"].includes(attributeName)) {
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

    return {
      ...Alchemy.TinymceDefaults,
      ...customConfig,
      locale: currentLocale(),
      selector: `#${this.editorId}`
    }
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
    let minHeight = this.configuration.min_height || 0

    if (Array.isArray(this.configuration.toolbar)) {
      minHeight += this.configuration.toolbar.length * TOOLBAR_ROW_HEIGHT
      minHeight += TOOLBAR_BORDER_WIDTH
    } else if (this.configuration.toolbar) {
      minHeight += TOOLBAR_ROW_HEIGHT
      minHeight += TOOLBAR_BORDER_WIDTH
    }
    if (this.configuration.statusbar) {
      minHeight += STATUSBAR_HEIGHT
    }
    minHeight += EDITOR_BORDER_WIDTH

    return minHeight
  }
}

customElements.define("alchemy-tinymce", Tinymce)
