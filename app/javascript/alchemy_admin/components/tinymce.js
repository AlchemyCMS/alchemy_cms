class Tinymce extends HTMLElement {
  constructor() {
    super()
    this.externalConfig = {}

    this.className = "tinymce_container"
    this.textarea.className = "has_tinymce"
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
    this.tinymceIntersectionObserver.observe(this)
  }

  /**
   * disconnect intersection observer and remove Tinymce editor if the web components get destroyed
   */
  disconnectedCallback() {
    if (this.tinymceIntersectionObserver !== null) {
      this.tinymceIntersectionObserver.disconnect()
    }

    tinymce.get(this.textareaId)?.remove(this.textareaId)
  }

  initTinymceEditor() {
    this.appendSpinner("small")

    const element = document
      .getElementById(this.textareaId)
      .closest(".element-editor")

    // initialize TinyMCE
    tinymce.init(this.configuration).then((editors) => {
      editors.forEach((editor) => {
        this.removeSpinner()

        // mark the editor container as visible
        // without these correction the editor remains hidden
        // after a drag and drop action
        editor.editorContainer.style.display = null

        // event listener to mark the editor as dirty
        editor.on("dirty", () => Alchemy.setElementDirty(element))
        editor.on("click", (event) => {
          event.target = element
          Alchemy.ElementEditors.onClickElement(event)
        })
      })
    })
  }

  appendSpinner() {
    const spinner = new Alchemy.Spinner("small")
    this.prepend(spinner.spin().el.get(0))
  }

  removeSpinner() {
    const spinners = this.getElementsByClassName("spinner")
    while (spinners.length > 0) {
      spinners[0].parentNode.removeChild(spinners[0])
    }
  }

  get textarea() {
    return this.getElementsByTagName("textarea")[0]
  }

  get textareaId() {
    return this.textarea.id
  }

  get configuration() {
    return {
      ...Alchemy.TinymceDefaults,
      ...this.externalConfig,
      locale: Alchemy.locale,
      selector: `#${this.textareaId}`
    }
  }

  set configuration(config) {
    this.externalConfig = config
  }
}

customElements.define("alchemy-tinymce", Tinymce)
