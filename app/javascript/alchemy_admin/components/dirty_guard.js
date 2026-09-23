import { checkPageDirtyness } from "alchemy_admin/dirty"

// Warns before a wrapped form or link takes the user away from a page that has
// unsaved element changes.
//
// Guards in the capture phase, so that a cancelled navigation never reaches
// Turbo's document level handlers, nor any component the guard sits in.
//
// Wrap an sl-tooltip, never the element inside it: Shoelace anchors to its
// first slotted child, and this element has no box of its own to anchor to.
class DirtyGuard extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this.#guard, true)
    this.addEventListener("click", this.#guard, true)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this.#guard, true)
    this.removeEventListener("click", this.#guard, true)
  }

  #guard = (event) => {
    const target =
      event.type === "submit" ? event.target : event.target.closest("a")
    if (!target) return

    if (!checkPageDirtyness(target)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }
}

customElements.define("alchemy-dirty-guard", DirtyGuard)
