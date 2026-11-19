// The tab row of pages locked by the current user. When the tabs do not fit,
// the row scrolls with faded edges and a menu lists all locked pages.
class LockedPages extends HTMLElement {
  #resizeObserver = null
  #mutationObserver = null

  connectedCallback() {
    this.#resizeObserver = new ResizeObserver(() => this.update())
    this.#resizeObserver.observe(this.list)
    this.#mutationObserver = new MutationObserver(() => this.update())
    this.#mutationObserver.observe(this.list, { childList: true })
    this.list.addEventListener("scroll", this.#updateFades)
    this.menu?.addEventListener("sl-show", this.#fillMenu)
    this.menuList?.addEventListener("submit", this.#closeMenu)
    this.update()
  }

  disconnectedCallback() {
    this.#resizeObserver?.disconnect()
    this.#mutationObserver?.disconnect()
    this.list.removeEventListener("scroll", this.#updateFades)
    this.menu?.removeEventListener("sl-show", this.#fillMenu)
    this.menuList?.removeEventListener("submit", this.#closeMenu)
  }

  update() {
    this.toggleAttribute(
      "overflowing",
      this.list.scrollWidth > this.list.clientWidth
    )
    this.#centerCurrent()
    if (this.count) this.count.textContent = this.tabs.length
    this.#updateFades()
  }

  // Centered, so the current page stays clear of the faded edges.
  #centerCurrent() {
    const current = this.list.querySelector(".locked_page.current")
    if (!current) return

    const tab = current.getBoundingClientRect()
    const list = this.list.getBoundingClientRect()
    this.list.scrollLeft +=
      tab.left + tab.width / 2 - (list.left + list.width / 2)
  }

  #updateFades = () => {
    const { scrollLeft, scrollWidth, clientWidth } = this.list
    this.toggleAttribute("fade-start", scrollLeft > 0)
    this.toggleAttribute("fade-end", scrollLeft + clientWidth < scrollWidth - 1)
  }

  // The menu shows copies of the tabs, so turbo streams only ever have to
  // update the tabs themselves.
  #fillMenu = () => {
    this.menuList.replaceChildren(
      ...this.tabs.map((tab) => {
        const copy = tab.cloneNode(true)
        copy.removeAttribute("id")
        copy.querySelectorAll("[id]").forEach((el) => el.removeAttribute("id"))
        return copy
      })
    )
  }

  #closeMenu = () => {
    this.menu.hide()
  }

  get list() {
    return this.querySelector(".locked-pages-list")
  }

  get tabs() {
    return Array.from(this.list.querySelectorAll(".locked_page"))
  }

  get menu() {
    return this.querySelector(".locked-pages-menu")
  }

  get menuList() {
    return this.querySelector(".locked-pages-menu-list")
  }

  get count() {
    return this.querySelector(".locked-pages-count")
  }
}

customElements.define("alchemy-locked-pages", LockedPages)
