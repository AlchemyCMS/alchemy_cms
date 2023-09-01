import { createHtmlElement, wrap } from "alchemy_admin/utils/dom_helpers"
import Spinner from "alchemy_admin/spinner"

class Tinymce extends HTMLTextAreaElement {
  constructor() {
    super()

    // create a wrapper around the the textarea and place everything inside that container
    this.container = createHtmlElement('<div class="tinymce_container" />')
    wrap(this, this.container)
    this.className = "has_tinymce"
  }

  /**
   * the observer will initialize Tinymce if the textarea becomes visible
   */
  connectedCallback() {
    const observerCallback = (entries, observer) => {
      entries.forEach((entry) => {
        if (entry.intersectionRatio > 0) {
          this.initTinymceEditor()
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
    this.tinymceIntersectionObserver.observe(this.container)
  }

  /**
   * disconnect intersection observer and remove Tinymce editor if the web components get destroyed
   */
  disconnectedCallback() {
    if (this.tinymceIntersectionObserver !== null) {
      this.tinymceIntersectionObserver.disconnect()
    }

    tinymce.get(this.id)?.remove(this.id)
  }

  initTinymceEditor() {
    const spinner = new Spinner("small")
    spinner.spin(this)

    // initialize TinyMCE
    tinymce.init(this.configuration).then((editors) => {
      spinner.stop()

      editors.forEach((editor) => {
        // mark the editor container as visible
        // without these correction the editor remains hidden
        // after a drag and drop action
        editor.show()

        const elementEditor = document
          .getElementById(this.id)
          .closest(".element-editor")

        // event listener to mark the editor as dirty
        editor.on("dirty", () => Alchemy.setElementDirty(elementEditor))
        editor.on("click", (event) => {
          event.target = elementEditor
          Alchemy.ElementEditors.onClickElement(event)
        })
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
      locale: Alchemy.locale,
      selector: `#${this.id}`
    }
  }
}

customElements.define("alchemy-tinymce", Tinymce, { extends: "textarea" })
