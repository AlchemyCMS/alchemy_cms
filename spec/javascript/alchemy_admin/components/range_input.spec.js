import "alchemy_admin/components/range_input"
import { renderComponent } from "./component.helper"

describe("alchemy-range-input", () => {
  let component

  beforeEach(() => {
    component = renderComponent(
      "alchemy-range-input",
      `
        <alchemy-range-input>
          <input type="range" min="0" max="10" value="2">
          <output>2</output>
        </alchemy-range-input>
      `
    )
  })

  const input = () => component.querySelector("input")
  const output = () => component.querySelector("output")

  it("shows the value of the range input on input", () => {
    input().value = "7"
    input().dispatchEvent(new Event("input"))
    expect(output().value).toEqual("7")
  })

  it("stops listening when disconnected", () => {
    const range = input()
    const display = output()
    component.remove()
    range.value = "7"
    range.dispatchEvent(new Event("input"))
    expect(display.value).toEqual("2")
  })
})
