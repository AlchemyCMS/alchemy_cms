import ajax, { get, post, patch, getToken } from "alchemy_admin/utils/ajax"

const JSON_CONTENT_TYPE = "application/json"
const token = "s3cr3t"

const successResponse = {
  ok: true,
  headers: { get: () => JSON_CONTENT_TYPE },
  json: async () => ({ success: true })
}

describe("ajax utilities", () => {
  beforeEach(() => {
    document.head.innerHTML = `<meta name="csrf-token" content="${token}">`
    global.fetch = jest.fn()
  })

  describe("getToken", () => {
    it("retrieves the CSRF token from the meta tag", () => {
      expect(getToken()).toBe(token)
    })

    it("throws an error if the meta tag is missing", () => {
      document.head.innerHTML = ""
      expect(() => getToken()).toThrow()
    })
  })

  describe("ajax", () => {
    it("sends a GET request with query parameters", async () => {
      global.fetch.mockResolvedValueOnce(successResponse)

      const response = await ajax("GET", "/test", { param1: "value1" })

      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost/test?param1=value1",
        expect.objectContaining({
          method: "GET",
          headers: expect.objectContaining({
            "X-CSRF-Token": token
          })
        })
      )
      expect(response.data).toEqual({ success: true })
    })

    it("sends a POST request with JSON body", async () => {
      global.fetch.mockResolvedValueOnce(successResponse)

      const response = await ajax("POST", "/test", { key: "value" })

      expect(global.fetch).toHaveBeenCalledWith(
        "http://localhost/test",
        expect.objectContaining({
          method: "POST",
          body: JSON.stringify({ key: "value" }),
          headers: expect.objectContaining({
            "Content-Type": "application/json; charset=utf-8",
            Accept: JSON_CONTENT_TYPE
          })
        })
      )
      expect(response.data).toEqual({ success: true })
    })

    it("throws an error for non-OK responses", async () => {
      global.fetch.mockResolvedValueOnce({
        ok: false,
        headers: { get: () => JSON_CONTENT_TYPE },
        json: async () => ({ error: "Something went wrong" })
      })

      await expect(ajax("GET", "/test")).rejects.toEqual({
        error: "Something went wrong"
      })
    })

    it("handles non-JSON responses gracefully", async () => {
      global.fetch.mockResolvedValueOnce({
        ok: true,
        headers: { get: () => "text/html" },
        text: async () => "<html></html>"
      })

      const response = await ajax("GET", "/test")

      expect(response.data).toBeNull()
    })
  })

  describe("get", () => {
    it("calls ajax with GET method", async () => {
      const ajaxSpy = jest
        .spyOn(global, "fetch")
        .mockResolvedValueOnce(successResponse)

      const response = await get("/test", { param: "value" })

      expect(ajaxSpy).toHaveBeenCalled()
      expect(response.data).toEqual({ success: true })
    })
  })

  describe("post", () => {
    it("calls ajax with POST method and default accept header", async () => {
      const ajaxSpy = jest
        .spyOn(global, "fetch")
        .mockResolvedValueOnce(successResponse)

      const response = await post("/test", { key: "value" })

      expect(ajaxSpy).toHaveBeenCalled()
      expect(response.data).toEqual({ success: true })
    })

    it("allows overriding the accept header", async () => {
      const ajaxSpy = jest.spyOn(global, "fetch").mockResolvedValueOnce({
        ok: true,
        headers: { get: () => "application/xml" },
        text: async () => "<response>success</response>"
      })

      const response = await post("/test", { key: "value" }, "application/xml")

      expect(ajaxSpy).toHaveBeenCalledWith(
        "http://localhost/test",
        expect.objectContaining({
          headers: expect.objectContaining({
            Accept: "application/xml"
          })
        })
      )
    })
  })

  describe("patch", () => {
    it("calls ajax with PATCH method", async () => {
      const ajaxSpy = jest
        .spyOn(global, "fetch")
        .mockResolvedValueOnce(successResponse)

      const response = await patch("/test", { key: "value" })

      expect(ajaxSpy).toHaveBeenCalled()
      expect(response.data).toEqual({ success: true })
    })
  })

  afterEach(() => {
    jest.resetAllMocks()
  })
})
