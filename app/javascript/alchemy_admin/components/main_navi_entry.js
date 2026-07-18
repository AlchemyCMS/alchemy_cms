import { autoUpdate, computePosition, flip } from "@floating-ui/dom"

const SCREEN_PADDING = 8

// A main navigation entry lives inside the fixed, vertically scrollable menu
// column. A scroll container clips its content in both axes, so the hover
// flyout (this entry's label or its sub navigation) that reaches out to the
// right of the column would be cut off. While the flyout is open we lift it out
// of the clipping context by fixing it to the viewport and let Floating UI keep
// it anchored to the entry.
class MainNaviEntry extends HTMLElement {
  #flyout = null
  #stopAutoUpdate = null

  connectedCallback() {
    this.addEventListener("mouseenter", this.#open)
    this.addEventListener("mouseleave", this.#close)
  }

  disconnectedCallback() {
    this.removeEventListener("mouseenter", this.#open)
    this.removeEventListener("mouseleave", this.#close)
    this.#close()
  }

  #open = () => {
    const flyout = this.#flyoutElement()
    if (!flyout) return

    this.#flyout = flyout
    this.#stopAutoUpdate = autoUpdate(this, flyout, () => {
      computePosition(this, flyout, {
        strategy: "fixed",
        placement: "right-start",
        // Keep the flyout anchored to the entry: when there is no room below,
        // flip to bottom alignment instead of drifting away from the entry.
        middleware: [
          flip({ fallbackPlacements: ["right-end"], padding: SCREEN_PADDING })
        ]
      }).then(({ x, y }) => {
        Object.assign(flyout.style, {
          position: "fixed",
          left: `${Math.round(x)}px`,
          top: `${Math.round(y)}px`
        })
      })
    })
  }

  #close = () => {
    this.#stopAutoUpdate?.()
    this.#stopAutoUpdate = null

    if (this.#flyout) {
      this.#flyout.style.position = ""
      this.#flyout.style.left = ""
      this.#flyout.style.top = ""
      this.#flyout = null
    }
  }

  // The entry's flyout element, but only when it is actually rendered as a
  // flyout. In the expanded menu the label and sub navigation sit in the normal
  // document flow (position: static) and must be left untouched.
  #flyoutElement() {
    const flyout =
      this.querySelector(".sub_navigation") || this.querySelector("label")
    if (!flyout || getComputedStyle(flyout).position === "static") return null
    return flyout
  }
}

customElements.define("alchemy-main-navi-entry", MainNaviEntry)

export default MainNaviEntry
