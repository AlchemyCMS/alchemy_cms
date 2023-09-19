import { toCamelCase } from "alchemy_admin/utils/string_conversions"

describe("toCamelCase", () => {
  it("convert dashes into camelCase", () => {
    expect(toCamelCase("foo-bar-bazzz")).toEqual("fooBarBazzz")
  })

  it("convert underscore into camelCase", () => {
    expect(toCamelCase("foo_bar")).toEqual("fooBar")
  })
})
