const MIN_WIDTH = 400
const MAX_WIDTH = 1000
class ElementsWindowHandle extends HTMLElement {
  #dragging = false
  #elementsWindow = null
  #previewWindow = null
  #minWidth = MIN_WIDTH
  #maxWidth = MAX_WIDTH

  constructor() {
    super()

    this.addEventListener("mousedown", this)
    window.addEventListener("mousemove", this)
    window.addEventListener("mouseup", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "mousedown":
        event.stopPropagation()
        this.onMouseDown()
        break
      case "mouseup":
        this.onMouseUp()
        break
      case "mousemove":
        if (this.#dragging) {
          this.onDrag(event.pageX)
        }
        break
    }
  }

  onMouseDown() {
    this.#dragging = true
    // Read the resolved min/max width the browser computed from the CSS
    // custom properties (incl. calc() and active media queries) once, so the
    // drag stays clamped to the same bounds the stylesheet defines.
    const styles = getComputedStyle(this.elementsWindow)
    this.#minWidth = parseFloat(styles.minWidth) || MIN_WIDTH
    this.#maxWidth =
      styles.maxWidth === "none" ? MAX_WIDTH : parseFloat(styles.maxWidth)
    this.elementsWindow.isDragged = true
    this.previewWindow.isDragged = true
    this.classList.add("is-dragged")
  }

  onMouseUp() {
    this.#dragging = false
    this.elementsWindow.isDragged = false
    this.previewWindow.isDragged = false
    this.classList.remove("is-dragged")
  }

  onDrag(pageX) {
    const elementWindowWidth = window.innerWidth - pageX
    const width = Math.min(
      Math.max(elementWindowWidth, this.#minWidth),
      this.#maxWidth
    )
    this.elementsWindow.resize(width)
  }

  get elementsWindow() {
    if (!this.#elementsWindow) {
      this.#elementsWindow = document.querySelector("alchemy-elements-window")
    }
    return this.#elementsWindow
  }

  get previewWindow() {
    if (!this.#previewWindow) {
      this.#previewWindow = document.getElementById("alchemy_preview_window")
    }
    return this.#previewWindow
  }
}

customElements.define("alchemy-elements-window-handle", ElementsWindowHandle)
