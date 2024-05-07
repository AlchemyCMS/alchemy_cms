import "alchemy_admin/components/remote_partial"

describe("alchemy-remote-partial", () => {
  /**
   * @type {RemotePartial | undefined}
   */
  let partial = undefined

  const renderComponent = (url = null) => {
    document.body.innerHTML = `<alchemy-remote-partial url="${url}"></alchemy-remote-partial>`
    partial = document.querySelector("alchemy-remote-partial")
    return new Promise((resolve) => {
      setTimeout(() => resolve())
    })
  }

  /**
   * @param {{
   *   ok: boolean|undefined,
   *   redirected: boolean|undefined,
   *   statusText: string|undefined,
   *   text: function|undefined
   *   }} response
   */
  const mockFetch = (response = {}) => {
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        redirected: false,
        statusText: "",
        text: () => Promise.resolve("Foo"),
        ...response
      })
    )
  }

  it("should render a spinner as initial content", () => {
    mockFetch()
    renderComponent()
    expect(document.querySelector("alchemy-spinner")).toBeTruthy()
  })

  it("should fetch the given url", () => {
    mockFetch()
    renderComponent("http://foo.bar")
    expect(fetch).toHaveBeenCalledWith("http://foo.bar", {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
  })

  describe("fetched url", () => {
    describe("successful response", () => {
      it("should replace the spinner with the fetched content", async () => {
        mockFetch()
        await renderComponent()
        expect(partial.innerHTML).toBe("Foo")
      })
    })

    describe("server errors", () => {
      it("doesn't respond", async () => {
        mockFetch()
        fetch.mockImplementationOnce(() => Promise.reject())

        await renderComponent()
        expect(partial.innerHTML).toContain("The server does not respond")
      })

      it("response with an error if the server response with an error", async () => {
        mockFetch({ ok: false, statusText: "Ruby Error" })

        await renderComponent()
        expect(partial.innerHTML).toContain("Ruby Error")
      })

      it("response with an redirect", async () => {
        mockFetch({ redirected: true })

        await renderComponent()
        expect(partial.innerHTML).toContain("You are not authorized!")
      })
    })
  })

  describe("jQuery Remote Call", () => {
    const dispatchCustomEvent = (
      eventName = "ajax:success",
      responseText = "Bar",
      contentType = "text/html"
    ) => {
      const event = new CustomEvent(eventName, {
        bubbles: true,
        detail: [
          {},
          eventName === "ajax:success" ? "OK" : "Error",
          {
            responseText,
            getResponseHeader: jest.fn().mockReturnValue(contentType)
          }
        ]
      })
      partial.dispatchEvent(event)
    }

    beforeEach(async () => {
      mockFetch()
      await renderComponent()
    })

    describe("ajax:success - event", () => {
      it("should replace the partial content with html response", () => {
        dispatchCustomEvent()
        expect(partial.innerHTML).toContain("Bar")
      })

      it("should not replace the partial content with json response", () => {
        dispatchCustomEvent("ajax:success", "Bar", "application/json")
        expect(partial.innerHTML).toContain("Foo")
      })
    })

    describe("ajax:error - event", () => {
      it("should replace the partial content with html response", () => {
        dispatchCustomEvent("ajax:error", "Very Broken")
        expect(partial.innerHTML).toContain("Very Broken")
      })
    })
  })
})
