// Syncs the node name and url fields with the selected page
export class NodeForm extends HTMLElement {
  connectedCallback() {
    this.addEventListener("Alchemy.RemoteSelect.Change", this.#onPageSelect)
  }

  disconnectedCallback() {
    this.removeEventListener("Alchemy.RemoteSelect.Change", this.#onPageSelect)
  }

  #onPageSelect = (event) => {
    const page = event.detail.added

    if (page) {
      this.nameField.setAttribute("placeholder", page.name)
      this.urlField.value = page.url_path
      this.urlField.setAttribute("disabled", "disabled")
    } else {
      this.nameField.removeAttribute("placeholder")
      this.urlField.value = ""
      this.urlField.removeAttribute("disabled")
    }
  }

  get nameField() {
    return this.querySelector("#node_name")
  }

  get urlField() {
    return this.querySelector("#node_url")
  }
}

customElements.define("alchemy-node-form", NodeForm)
