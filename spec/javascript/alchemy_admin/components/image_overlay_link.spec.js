import { vi } from "vitest"
import "alchemy_admin/components/image_overlay_link"
import ImageOverlay from "alchemy_admin/image_overlay"
import { renderComponent } from "./component.helper"

describe("alchemy-image-overlay-link", () => {
  it("opens an image overlay for its own href on click", () => {
    const openSpy = vi.spyOn(ImageOverlay.prototype, "open").mockImplementation()
    const link = renderComponent(
      "alchemy-image-overlay-link",
      `<a is="alchemy-image-overlay-link" href="http://localhost/admin/pictures/1">
        <alchemy-picture-thumbnail></alchemy-picture-thumbnail>
      </a>`
    )

    link.querySelector("alchemy-picture-thumbnail").click()

    expect(openSpy).toHaveBeenCalled()
    expect(link.dialog.url).toEqual("http://localhost/admin/pictures/1")
  })

  it("prevents navigating to the picture page", () => {
    vi.spyOn(ImageOverlay.prototype, "open").mockImplementation()
    const link = renderComponent(
      "alchemy-image-overlay-link",
      `<a is="alchemy-image-overlay-link" href="http://localhost/admin/pictures/1"></a>`
    )
    const click = new Event("click", { bubbles: true, cancelable: true })

    link.dispatchEvent(click)

    expect(click.defaultPrevented).toBeTruthy()
  })
})
