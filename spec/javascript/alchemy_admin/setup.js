import { vi } from "vitest"
import jQuery from "jquery"

// Make jQuery available globally
globalThis.$ = jQuery
globalThis.jQuery = jQuery

// Mock select2 to avoid network requests in jsdom environment
globalThis.jQuery.fn.select2 = function (options) {
  // Mock select2 initialization
  const $element = this

  // Add basic select2 classes and structure for tests
  if (!$element.next(".select2-container").length) {
    const container = jQuery(
      '<div class="select2-container alchemy_selectbox"></div>'
    )

    // Add clear button if allowClear is enabled
    if (options?.allowClear) {
      container.append('<span class="select2-search-choice-close"></span>')
    }

    $element.after(container)
  }

  return $element
}

// Mock select2 static methods if needed
globalThis.jQuery.fn.select2.defaults = {}

// Mock TinyMCE to avoid network requests in jsdom environment
globalThis.tinymce = {
  init: vi.fn().mockResolvedValue([]),
  get: vi.fn().mockReturnValue({
    remove: vi.fn(),
    show: vi.fn(),
    on: vi.fn()
  }),
  remove: vi.fn()
}

// Mock select2 module to avoid network requests
vi.mock("select2", () => ({}))

// Mock dynamic imports to avoid network requests
vi.mock("flatpickr/en.js", () => ({}))
vi.mock("flatpickr/de.js", () => ({}))
vi.mock("flatpickr/es.js", () => ({}))
vi.mock("flatpickr/fr.js", () => ({}))
vi.mock("flatpickr/it.js", () => ({}))
vi.mock("flatpickr/nl.js", () => ({}))
vi.mock("flatpickr/pt.js", () => ({}))
vi.mock("flatpickr/ru.js", () => ({}))
vi.mock("flatpickr/zh.js", () => ({}))

// Mock fetch to avoid network requests
globalThis.fetch = vi.fn().mockResolvedValue({
  ok: true,
  status: 200,
  json: vi.fn().mockResolvedValue({}),
  text: vi.fn().mockResolvedValue(""),
  headers: {
    get: vi.fn().mockReturnValue("application/json")
  }
})

// Mock XMLHttpRequest to avoid network requests
globalThis.XMLHttpRequest = vi.fn(function () {
  this.open = vi.fn()
  this.send = vi.fn()
  this.setRequestHeader = vi.fn()
  this.abort = vi.fn()
  this.status = 200
  this.readyState = 4
  this.responseText = ""
  this.response = ""
  this.upload = {
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    onprogress: vi.fn()
  }
  this.addEventListener = vi.fn()
  this.removeEventListener = vi.fn()
})

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
  LinkDialog: vi.fn(function () {
    this.open = vi.fn()
  }),
  currentDialog: vi.fn(),
  uploader_defaults: {},
  PreviewWindow: {
    postMessage: vi.fn(),
    refresh: vi.fn()
  }
}
