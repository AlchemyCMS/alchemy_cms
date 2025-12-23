class PictureDescriptionSelect extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("change", this)
  }

  handleEvent(event) {
    switch (event.type) {
      case "change":
        this.onChange()
        break
    }
  }

  onChange() {
    const url = new URL(this.getAttribute("url"))
    const select = this.querySelector("select")
    url.searchParams.set("language_id", select.value)
    Turbo.visit(url, { frame: "picture_descriptions" })
  }
}

customElements.define(
  "alchemy-picture-description-select",
  PictureDescriptionSelect
)
