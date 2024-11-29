class ElementsWindowHandle extends HTMLElement {
  #dragging = false
  #elementsWindow = null
  #previewWindow = null

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
    this.elementsWindow.resize(elementWindowWidth)
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
