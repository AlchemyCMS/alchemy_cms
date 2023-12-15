import { formatFileSize } from "alchemy_admin/utils/format"

describe("formatFileSize", () => {
  it("converts bytes", () => {
    expect(formatFileSize(123)).toEqual("123.00 B")
  })

  it("converts kilo bytes", () => {
    expect(formatFileSize(12345)).toEqual("12.06 kB")
  })

  it("converts mega bytes", () => {
    expect(formatFileSize(12345678)).toEqual("11.77 MB")
  })

  it("converts giga bytes", () => {
    expect(formatFileSize(12345678901)).toEqual("11.50 GB")
  })
})
