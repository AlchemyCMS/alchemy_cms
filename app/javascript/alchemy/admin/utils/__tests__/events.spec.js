import { on } from "../events"

describe("on", () => {
  const callback = jest.fn()

  beforeEach(() => {
    document.body.innerHTML = `
      <ul class="list">
        <li class="first item"><span>One</span></li>
        <li class="second item">Two</li>
      </ul>
    `
  })

  it("adds event listener to base node", () => {
    const baseNode = document.querySelector(".list")
    const spy = jest.spyOn(baseNode, "addEventListener")
    on("click", ".list", ".item", callback)
    expect(spy).toHaveBeenCalledWith("click", expect.any(Function))
    spy.mockReset()
  })

  it("event triggered on matching child node calls callback", () => {
    const childNode = document.querySelector(".first.item")
    on("click", ".list", ".item", callback)
    childNode.click()
    expect(callback).toHaveBeenCalledWith(expect.any(MouseEvent))
  })

  it("event triggered on child of registered target still calls callback", () => {
    const child = document.querySelector(".first.item span")
    on("click", ".list", ".item", callback)
    child.click()
    expect(callback).toHaveBeenCalledWith(expect.any(MouseEvent))
  })

  afterEach(() => callback.mockReset())
})
