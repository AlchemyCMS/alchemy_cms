import max from "alchemy_admin/utils/max.js"

describe("max", () => {
  it("should return the maximum value between two numbers", () => {
    expect(max(2, 5)).toBe(5)
    expect(max(-10, 0)).toBe(0)
    expect(max(100, 100)).toBe(100)
  })

  it("should return the maximum value between two negative numbers", () => {
    expect(max(-5, -2)).toBe(-2)
    expect(max(-10, -10)).toBe(-10)
    expect(max(-100, -50)).toBe(-50)
  })

  it("should return the maximum value between a positive and a negative number", () => {
    expect(max(5, -2)).toBe(5)
    expect(max(-10, 10)).toBe(10)
    expect(max(-100, 50)).toBe(50)
  })
})
