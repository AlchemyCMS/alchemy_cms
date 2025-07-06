import { vi } from "vitest"
import jQuery from "jquery"

// Make jQuery available globally
globalThis.$ = jQuery
globalThis.jQuery = jQuery

// Import select2 and make it available
import("select2")

// Mock matchMedia for components that use it
Object.defineProperty(window, "matchMedia", {
  writable: true,
  value: vi.fn().mockImplementation((query) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(), // deprecated
    removeListener: vi.fn(), // deprecated
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn()
  }))
})

// Set up global Alchemy object that many tests expect
globalThis.Alchemy = {
  translations: {},
  locale: "en",
  growl: vi.fn(),
  routes: {},
  LinkDialog: vi.fn(() => ({ open: vi.fn() })),
  currentDialog: vi.fn(),
  uploader_defaults: {},
  PreviewWindow: {
    postMessage: vi.fn(),
    refresh: vi.fn()
  }
}
