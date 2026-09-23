import Dirty from "alchemy_admin/dirty"

// The unsaved changes guard sits on the navigation container instead of the
// single entries, so that it also covers links a host application yields into
// the navigation.
class MainNavi extends HTMLElement {
  connectedCallback() {
    this.addEventListener("click", this.#guardNavigation)
  }

  disconnectedCallback() {
    this.removeEventListener("click", this.#guardNavigation)
  }

  #guardNavigation = (event) => {
    const link = event.target.closest("a")
    if (!link) return

    if (!Dirty.checkPageDirtyness(link)) {
      event.preventDefault()
    }
  }
}

customElements.define("alchemy-main-navi", MainNavi)

export default MainNavi
