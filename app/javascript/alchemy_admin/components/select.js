class Select extends HTMLSelectElement {
  constructor() {
    super()
    if (this.options.length >= 5) {
      this.items = []
      this.classList.add("hidden")
      this.createWrapper()
      this.createInput()
      this.createList()
    }
  }

  get options() {
    return this.querySelectorAll("option")
  }

  createWrapper() {
    this.wrapper = document.createElement("div")
    this.wrapper.classList.add("alchemy-select", "closed")
    this.after(this.wrapper)
  }

  createInput() {
    this.inputField = document.createElement("input")
    this.inputField.classList.add("alchemy-select--input")
    this.inputField.setAttribute("name", this.name)
    // this.inputField.placeholder = Alchemy.t("search")
    this.wrapper.appendChild(this.inputField)
  }

  createList() {
    this.datalist = document.createElement("datalist")
    this.datalist.id = this.name
    this.options.forEach((option) => {
      if (option.value) {
        this.datalist.appendChild(option)
      }
      if (option.selected) {
        this.inputField.value = option.textContent
      }
    })
    this.datalist.classList.add("alchemy-select--menu", "closed")
    this.wrapper.appendChild(this.datalist)
    this.inputField.setAttribute("list", this.datalist.id)
  }
}

customElements.define("alchemy-select", Select, { extends: "select" })
