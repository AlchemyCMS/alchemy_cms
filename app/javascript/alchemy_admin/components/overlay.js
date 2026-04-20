class Overlay extends HTMLElement {
  connectedCallback() {
    this.innerHTML = `
      <alchemy-spinner></alchemy-spinner>
      <div id="overlay_text_box">
        <span id="overlay_text">${this.getAttribute("text") ?? ""}</span>
      </div>
    `
  }

  set show(value) {
    this.classList.toggle("visible", value)
  }
}

customElements.define("alchemy-overlay", Overlay)
