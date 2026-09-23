import ImageOverlay from "alchemy_admin/image_overlay"

describe("ImageOverlay", () => {
  it("leaves its dimensions to the stylesheet", () => {
    const overlay = new ImageOverlay("http://localhost/admin/pictures/1")

    expect(overlay.dialog.style.width).toEqual("")
    expect(overlay.dialog.style.minHeight).toEqual("")
    expect(overlay.dialog_body.style.minHeight).toEqual("")
  })
})
