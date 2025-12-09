window.Alchemy = Alchemy || {}

Object.assign(Alchemy, {
  ElementSelector: {
    styles: {
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
    },

    init() {
      window.addEventListener("message", (event) => {
        switch (event.data.message) {
          case "Alchemy.blurElements":
            this.blurElements()
            break
          case "Alchemy.focusElement":
            this.focusElement(event.data)
            break
          default:
            console.info("Received unknown message!", event.data)
        }
      })
      this.elements = Array.from(
        document.querySelectorAll("[data-alchemy-element]")
      )
      this.elements.forEach((element) => {
        element.addEventListener("mouseover", () => {
          if (!element.classList.contains("selected")) {
            Object.assign(element.style, this.getStyle("hover"))
          }
        })
        element.addEventListener("mouseout", () => {
          if (!element.classList.contains("selected")) {
            Object.assign(element.style, this.getStyle("reset"))
          }
        })
        element.addEventListener("click", (e) => {
          e.stopPropagation()
          e.preventDefault()
          this.selectElement(element)
          this.focusElementEditor(element)
        })
      })
    },

    // Mark element in preview frame as selected and scrolls to it.
    selectElement(element) {
      this.blurElements(element)
      element.classList.add("selected")
      Object.assign(element.style, this.getStyle("selected"))
      element.scrollIntoView({
        behavior: "smooth",
        block: "start"
      })
    },

    // Blur all elements in preview frame.
    blurElements(selectedElement) {
      this.elements.forEach((element) => {
        if (element !== selectedElement) {
          element.classList.remove("selected")
          Object.assign(element.style, this.getStyle("reset"))
        }
      })
    },

    // Focus the element in the Alchemy preview window.
    focusElement(data) {
      const element = this.getElement(data.element_id)
      if (element) {
        return this.selectElement(element)
      } else {
        return console.warn("Could not focus element with id", data.element_id)
      }
    },

    getElement(element_id) {
      return this.elements.find(
        (element) => element.dataset.alchemyElement === element_id.toString()
      )
    },

    // Focus the element editor in the Alchemy element window.
    focusElementEditor(element) {
      const element_id = element.dataset.alchemyElement
      window.parent.postMessage(
        {
          message: "Alchemy.focusElementEditor",
          element_id
        },
        window.location.origin
      )
    },

    getStyle(state) {
      if (state === "reset") {
        return this.styles["reset"]
      } else {
        return this.styles[state]
      }
    }
  }
})

Alchemy.ElementSelector.init()

// Notify parent window that preview is ready
window.parent.postMessage(
  {
    message: "Alchemy.previewReady"
  },
  window.location.origin
)
