import debounce from "alchemy_admin/utils/debounce.js"

describe("debounce", () => {
  let mockFunc
  let debouncedFunc

  beforeEach(() => {
    jest.useFakeTimers()
    mockFunc = jest.fn()
    debouncedFunc = debounce(mockFunc, 1000)
  })

  afterEach(() => {
    jest.clearAllTimers()
  })

  it("should debounce the function", () => {
    debouncedFunc()
    debouncedFunc()
    debouncedFunc()

    expect(mockFunc).not.toBeCalled()

    jest.runAllTimers()

    expect(mockFunc).toBeCalled()
    expect(mockFunc).toHaveBeenCalledTimes(1)
  })

  it("should debounce the function with the specified delay", () => {
    debouncedFunc()
    jest.advanceTimersByTime(500)
    debouncedFunc()
    jest.advanceTimersByTime(500)
    debouncedFunc()

    expect(mockFunc).not.toBeCalled()

    jest.runAllTimers()

    expect(mockFunc).toBeCalled()
    expect(mockFunc).toHaveBeenCalledTimes(1)
  })
})
