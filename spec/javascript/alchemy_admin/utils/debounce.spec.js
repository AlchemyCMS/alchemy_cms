import { vi } from "vitest"
import debounce from "alchemy_admin/utils/debounce.js"

describe("debounce", () => {
  let mockFunc
  let debouncedFunc

  beforeEach(() => {
    vi.useFakeTimers()
    mockFunc = vi.fn()
    debouncedFunc = debounce(mockFunc, 1000)
  })

  afterEach(() => {
    vi.clearAllTimers()
  })

  it("should debounce the function", () => {
    debouncedFunc()
    debouncedFunc()
    debouncedFunc()

    expect(mockFunc).not.toBeCalled()

    vi.runAllTimers()

    expect(mockFunc).toBeCalled()
    expect(mockFunc).toHaveBeenCalledTimes(1)
  })

  it("should debounce the function with the specified delay", () => {
    debouncedFunc()
    vi.advanceTimersByTime(500)
    debouncedFunc()
    vi.advanceTimersByTime(500)
    debouncedFunc()

    expect(mockFunc).not.toBeCalled()

    vi.runAllTimers()

    expect(mockFunc).toBeCalled()
    expect(mockFunc).toHaveBeenCalledTimes(1)
  })
})
