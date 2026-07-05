/**
 * Auto-rotating carousel for the dashboard news widget.
 *
 * Paging is handled by CSS scroll snap on `.news-reader--track`; this component
 * scrolls to the next slide on a timer (pausing while hovered), lets the user
 * swipe/scroll manually, and keeps the dot indicators in sync with the scroll
 * position.
 */
class NewsReader extends HTMLElement {
  connectedCallback() {
    this.track = this.querySelector(".news-reader--track")
    this.slides = Array.from(this.querySelectorAll(".news-reader--item"))
    if (!this.track || this.slides.length < 2) return

    this.currentIndex = 0
    this.createDots()
    this.setActive(0)
    this.startRotation()

    this.addEventListener("mouseenter", this)
    this.addEventListener("mouseleave", this)
    this.track.addEventListener("scroll", this, { passive: true })
  }

  disconnectedCallback() {
    this.stopRotation()
  }

  handleEvent(event) {
    switch (event.type) {
      case "mouseenter":
        this.stopRotation()
        break
      case "mouseleave":
        this.startRotation()
        break
      case "scroll":
        this.syncActiveToScroll()
        break
    }
  }

  createDots() {
    this.dotList = document.createElement("div")
    this.dotList.className = "news-reader--dots"
    this.dots = this.slides.map((_, index) => {
      const dot = document.createElement("button")
      dot.type = "button"
      dot.className = "news-reader--dot"
      dot.setAttribute("aria-label", `${index + 1}`)
      dot.addEventListener("click", () => {
        this.goTo(index)
        this.startRotation()
      })
      this.dotList.append(dot)
      return dot
    })
    this.append(this.dotList)
  }

  goTo(index) {
    this.currentIndex = index
    this.slides[index].scrollIntoView({
      behavior: "smooth",
      inline: "start",
      block: "nearest"
    })
    this.setActive(index)
  }

  next() {
    this.goTo((this.currentIndex + 1) % this.slides.length)
  }

  // Keep the active dot in sync when the user scrolls the track manually.
  syncActiveToScroll() {
    const width = this.track.clientWidth
    if (!width) return
    const index = Math.round(this.track.scrollLeft / width)
    if (index !== this.currentIndex && this.slides[index]) {
      this.currentIndex = index
      this.setActive(index)
    }
  }

  setActive(index) {
    this.dots.forEach((dot, i) => {
      dot.classList.toggle("is-active", i === index)
    })
  }

  startRotation() {
    this.stopRotation()
    this.timer = window.setInterval(() => this.next(), this.interval)
  }

  stopRotation() {
    if (this.timer) window.clearInterval(this.timer)
    this.timer = null
  }

  get interval() {
    return parseInt(this.getAttribute("interval"), 10) || 8000
  }
}

customElements.define("alchemy-news-reader", NewsReader)

export default NewsReader
