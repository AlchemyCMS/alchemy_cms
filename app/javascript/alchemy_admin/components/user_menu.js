// The timezone select renders its options into the body, so Shoelace takes
// a click on an option as a click outside the menu and closes it before the
// option is picked. During such a click the whole body counts as the menu.
class UserMenu extends HTMLElement {
  connectedCallback() {
    document.addEventListener("mousedown", this.#onMousedown, true)
  }

  disconnectedCallback() {
    document.removeEventListener("mousedown", this.#onMousedown, true)
  }

  #onMousedown = (event) => {
    const dropdown = this.querySelector("sl-dropdown")
    if (!dropdown?.open) return
    if (!event.target.closest?.(".ts-dropdown, .ts-dropdown-mask")) return

    const { containingElement } = dropdown
    dropdown.containingElement = document.body
    setTimeout(() => {
      dropdown.containingElement = containingElement
    })
  }
}

customElements.define("alchemy-user-menu", UserMenu)
