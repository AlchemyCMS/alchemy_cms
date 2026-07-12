import { vi } from "vitest"

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

// jsdom does not implement the dialog element's methods yet
if (!window.HTMLDialogElement.prototype.showModal) {
  window.HTMLDialogElement.prototype.show = function () {
    this.open = true
  }
  window.HTMLDialogElement.prototype.showModal = function () {
    this.open = true
  }
  window.HTMLDialogElement.prototype.close = function () {
    this.open = false
  }
}

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

// Mock keymaster (key) for keyboard shortcuts
globalThis.key = vi.fn()
globalThis.key.unbind = vi.fn()

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
