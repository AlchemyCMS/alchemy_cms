import { describe, it, expect, beforeEach, afterEach, vi } from "vitest"
import "alchemy_admin/components/news_reader"
import { renderComponent } from "./component.helper"

describe("alchemy-news-reader", () => {
  let component

  const html = `
    <alchemy-news-reader interval="1000">
      <div class="news-reader--track">
        <article class="news-reader--item"><a>One</a></article>
        <article class="news-reader--item"><a>Two</a></article>
        <article class="news-reader--item"><a>Three</a></article>
      </div>
    </alchemy-news-reader>
  `

  const slides = () => component.querySelectorAll(".news-reader--item")
  const dots = () => component.querySelectorAll(".news-reader--dot")

  beforeEach(() => {
    vi.useFakeTimers()
    component = renderComponent("alchemy-news-reader", html)
    // jsdom does not lay out or scroll, so stub scrollIntoView on each slide.
    slides().forEach((slide) => {
      slide.scrollIntoView = vi.fn()
    })
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it("creates one dot indicator per slide", () => {
    expect(dots().length).toBe(3)
  })

  it("marks the first slide's dot active initially", () => {
    expect(dots()[0].classList.contains("is-active")).toBe(true)
  })

  it("scrolls to the next slide after the interval", () => {
    vi.advanceTimersByTime(1000)
    expect(slides()[1].scrollIntoView).toHaveBeenCalled()
    expect(dots()[1].classList.contains("is-active")).toBe(true)
  })

  it("wraps around to the first slide", () => {
    vi.advanceTimersByTime(3000)
    expect(dots()[0].classList.contains("is-active")).toBe(true)
  })

  it("scrolls to a slide when its dot is clicked", () => {
    dots()[2].click()
    expect(slides()[2].scrollIntoView).toHaveBeenCalled()
    expect(dots()[2].classList.contains("is-active")).toBe(true)
  })

  it("pauses rotation while hovered", () => {
    component.dispatchEvent(new Event("mouseenter"))
    vi.advanceTimersByTime(2000)
    expect(dots()[0].classList.contains("is-active")).toBe(true)
    expect(slides()[1].scrollIntoView).not.toHaveBeenCalled()
  })
})
