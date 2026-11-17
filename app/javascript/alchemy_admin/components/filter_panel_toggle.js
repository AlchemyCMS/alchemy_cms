class FilterPanelToggle extends HTMLElement {
  connectedCallback() {
    this.addEventListener("click", this)
  }

  disconnectedCallback() {
    this.removeEventListener("click", this)
  }

  handleEvent() {
    const collapsed = document.body.classList.toggle("filter-panel-collapsed")
    document.cookie = `alchemy-filter-panel-collapsed=${collapsed}; SameSite=Lax; Path=/;`
  }
}

customElements.define("alchemy-filter-panel-toggle", FilterPanelToggle)
