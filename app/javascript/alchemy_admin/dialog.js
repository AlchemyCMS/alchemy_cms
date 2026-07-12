import Hotkeys from "alchemy_admin/hotkeys"
import Spinner from "alchemy_admin/spinner"
import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"
import { dispatchCustomEvent } from "alchemy_admin/utils/events"

// Collection of all current dialog instances
const currentDialogs = []

const DEFAULTS = {
  header_height: 36,
  size: "400x300",
  padding: true,
  title: "",
  modal: true,
  overflow: "visible",
  ready: () => {},
  closed: () => {}
}

export class Dialog {
  #previousFlashParent = null
  #closing = false

  // Arguments:
  //  - url: The url to load the content from via ajax
  //  - options: A object holding options
  //    - size: The maximum size of the Dialog
  //    - title: The title of the Dialog
  constructor(url, options = {}) {
    this.url = url
    this.options = { ...DEFAULTS, ...options }
    const size = this.options.size.split("x")
    this.width = parseInt(size[0], 10)
    this.height = parseInt(size[1], 10)
    this.build()
    this.resize()
  }

  // Opens the Dialog and loads the content via ajax.
  open() {
    dispatchCustomEvent(this.dialog, "Alchemy.DialogOpen")
    this.bind_close_events()
    if (this.options.modal) {
      this.dialog_container.showModal()
      this.#adoptFlashNotices()
    } else {
      this.dialog_container.show()
    }
    window.requestAnimationFrame(() => {
      this.dialog_container.classList.add("open")
    })
    document.body.classList.add("prevent-scrolling")
    currentDialogs.push(this)
    this.load()
  }

  // Closes the Dialog and removes it from the DOM
  close() {
    // The container stays open during the closing transition, so close() can be
    // called again mid-fade (mashing Esc, a double click on the close button or
    // backdrop). Guard against re-entry, otherwise a second transitionend
    // listener is registered and the teardown runs twice.
    if (this.#closing) {
      return true
    }
    this.#closing = true
    dispatchCustomEvent(this.dialog, "DialogClose.Alchemy")
    this.dialog_container.classList.remove("open")
    this.dialog_container.addEventListener(
      "transitionend",
      () => {
        // Move the flash notices back out before removing the container, so
        // they are not destroyed together with the dialog.
        this.#releaseFlashNotices()
        this.dialog_container.close()
        this.dialog_container.remove()
        document.body.classList.remove("prevent-scrolling")
        currentDialogs.pop()
        if (this.options.closed != null) {
          this.options.closed()
        }
      },
      { once: true }
    )
    return true
  }

  // A modal <dialog> makes everything outside its subtree inert, so flash
  // notices rendered on the body would be visible but not interactable while
  // the dialog is open. Move them into the dialog, which is in the top layer
  // and not inert, for the dialog's lifetime and restore them on close.
  #adoptFlashNotices() {
    const flashNotices = document.getElementById("flash_notices")
    if (flashNotices) {
      this.#previousFlashParent = flashNotices.parentElement
      this.dialog_container.append(flashNotices)
      this.#clearTransientNotices(flashNotices)
    }
  }

  #releaseFlashNotices() {
    const flashNotices = document.getElementById("flash_notices")
    if (flashNotices && this.#previousFlashParent) {
      this.#previousFlashParent.append(flashNotices)
      this.#clearTransientNotices(flashNotices)
    }
  }

  // Only the persistent error notices need to travel with the dialog to stay
  // interactable. Moving the auto-dismissing ones would restart their dismiss
  // timers (their connectedCallback re-arms the timer), making them linger, so
  // remove them instead. A fade-out is skipped on purpose: the just-moved
  // element has no transition baseline, so dismiss()'s transitionend would never
  // fire and the node would be stranded invisible-but-present.
  #clearTransientNotices(flashNotices) {
    flashNotices
      .querySelectorAll('alchemy-message[dismissable]:not([type="error"])')
      .forEach((message) => message.remove())
  }

  // Loads the content via ajax and replaces the Dialog body with server response.
  load() {
    this.show_spinner()
    fetch(this.url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
      .then(async (response) => {
        const responseText = await response.text()
        if (response.ok) {
          this.replace(responseText)
        } else {
          this.show_error({
            status: response.status,
            statusText: response.statusText,
            responseText
          })
        }
      })
      .catch(() => {
        this.show_error({ status: 0 })
      })
  }

  // Reloads the Dialog content
  reload() {
    this.dialog_body.innerHTML = ""
    this.load()
  }

  // Replaces the dialog body with given content and initializes it.
  replace(data) {
    this.remove_spinner()
    this.dialog_body.style.display = "none"
    this.dialog_body.innerHTML = data
    this.init()
    dispatchCustomEvent(this.dialog, "DialogReady.Alchemy", {
      body: this.dialog_body
    })
    if (this.options.ready != null) {
      this.options.ready(this.dialog_body)
    }
    this.dialog_body.style.display = ""
  }

  // Adds a spinner into Dialog body
  show_spinner() {
    this.spinner = new Spinner("medium")
    this.spinner.spin(this.dialog_body)
  }

  // Removes the spinner from Dialog body
  remove_spinner() {
    this.spinner.stop()
  }

  // Initializes the Dialog body
  init() {
    Hotkeys(this.dialog_body)
    this.watch_remote_forms()
    window.requestAnimationFrame(() => this.#focusInitialElement())
  }

  // Shoelace tab panels (link, page configure) only render a few frames after
  // the content loaded, so their fields can not take focus yet. Hence the retry.
  #focusInitialElement(attempts = 0) {
    const target =
      this.dialog_body.querySelector("[autofocus]") ??
      this.dialog_body.querySelector("form [type='submit']")
    target?.focus()
    if (document.activeElement === this.close_button && attempts < 20) {
      window.requestAnimationFrame(() =>
        this.#focusInitialElement(attempts + 1)
      )
    }
  }

  // Watches ajax requests inside of dialog body and replaces the content accordingly
  watch_remote_forms() {
    this.dialog_body
      .querySelectorAll('[data-remote="true"]')
      .forEach((form) => {
        form.addEventListener("ajax:success", (event) => {
          const xhr = event.detail[2]
          const content_type = xhr.getResponseHeader("Content-Type")
          if (content_type.match(/javascript/)) {
            return
          } else {
            this.dialog_body.innerHTML = xhr.responseText
            this.init()
          }
        })

        form.addEventListener("ajax:error", (event) => {
          const statusText = event.detail[1]
          const xhr = event.detail[2]
          this.show_error(xhr, statusText)
        })
      })
  }

  // Displays an error message
  show_error(xhr, statusText) {
    if (xhr.status === 422) {
      this.dialog_body.innerHTML = xhr.responseText
      this.init()
      return
    }

    const { error_body, error_header, error_type } = this.error_messages(
      xhr,
      statusText
    )

    this.dialog_body.innerHTML = `<alchemy-message type="${error_type}">
      <h1>${error_header}</h1>
      <p>${error_body}</p>
    </alchemy-message>`
  }

  // Returns error message based on xhr status
  error_messages(xhr, statusText) {
    let error_body,
      error_header,
      error_type = "warning"

    switch (xhr.status) {
      case 0:
        error_header = "The server does not respond."
        error_body = "Please check server and try again."
        break
      case 403:
        error_header = "You are not authorized!"
        error_body = "Please close this window."
        break
      default:
        error_type = "error"
        if (statusText) {
          error_header = statusText
          console.error(xhr.responseText)
        } else {
          error_header = `${xhr.statusText} (${xhr.status})`
        }
        error_body = "Please check log and try again."
    }

    return { error_header, error_body, error_type }
  }

  // Binds close events on:
  // - Close button
  // - Overlay (if the Dialog is a modal)
  // - ESC Key (the dialog element's cancel event)
  bind_close_events() {
    this.close_button.addEventListener("click", (e) => {
      e.preventDefault()
      this.close()
    })
    this.dialog_container.classList.add("closable")
    // Use pointerdown, not click: a click whose mousedown and mouseup land on
    // different nodes is dispatched to their common ancestor — this element for
    // anything inside the dialog — closing it although the backdrop was never
    // hit, e.g. when selecting text and releasing outside.
    this.dialog_container.addEventListener("pointerdown", (e) => {
      if (e.target === this.dialog_container) {
        this.close()
      }
    })
    this.dialog_container.addEventListener("cancel", (e) => {
      e.preventDefault()
      this.close()
    })
  }

  // Builds the html structure of the Dialog
  build() {
    this.dialog_container = createHtmlElement(
      '<dialog class="alchemy-dialog-container"></dialog>'
    )
    this.dialog = createHtmlElement('<div class="alchemy-dialog"></div>')
    this.dialog_body = createHtmlElement(
      '<div class="alchemy-dialog-body"></div>'
    )
    this.dialog_header = createHtmlElement(
      '<div class="alchemy-dialog-header"></div>'
    )
    this.dialog_title = createHtmlElement(
      '<div class="alchemy-dialog-title"></div>'
    )
    this.close_button = createHtmlElement(
      '<button class="alchemy-dialog-close"><alchemy-icon name="close"></alchemy-icon></button>'
    )
    this.dialog_title.textContent = this.options.title
    this.dialog_header.append(this.dialog_title)
    this.dialog_header.append(this.close_button)
    this.dialog.append(this.dialog_header)
    this.dialog.append(this.dialog_body)
    this.dialog_container.append(this.dialog)
    if (this.options.modal) {
      this.dialog.classList.add("modal")
    }
    if (this.options.padding) {
      this.dialog_body.classList.add("padded")
    }
    document.body.append(this.dialog_container)
  }

  // Sets the correct size of the dialog
  // It normalizes the given size, so that it never acceeds the window size.
  resize() {
    const { width, height } = this.getSize()

    this.dialog.style.width = `${width}px`
    this.dialog.style.minHeight = `${height}px`
    this.dialog.style.overflow = this.options.overflow

    if (this.options.overflow === "hidden") {
      this.dialog_body.style.height = `${height}px`
      this.dialog_body.style.overflow = "auto"
    } else {
      this.dialog_body.style.minHeight = `${height}px`
      this.dialog_body.style.overflow = "visible"
    }
  }

  getSize() {
    const padding = this.options.padding ? 16 : 0
    const doc_width = window.innerWidth
    const doc_height = window.innerHeight

    let width = this.width
    let height = this.height

    if (width >= doc_width) {
      width = doc_width - padding
    }

    if (height >= doc_height) {
      height = doc_height - padding - DEFAULTS.header_height
    }

    return { width, height }
  }
}

// Gets the last dialog instantiated, which is the current one.
export function currentDialog() {
  const { length } = currentDialogs
  if (length === 0) {
    return
  }
  return currentDialogs[length - 1]
}

// Utility function to close the current Dialog
//
// You can pass a callback function, that gets triggered after the Dialog gets closed.
//
export function closeCurrentDialog(callback) {
  const dialog = currentDialog()
  if (dialog != null) {
    dialog.options.closed = callback
    return dialog.close()
  }
}

// Utility function to open a new Dialog
export function openDialog(url, options) {
  if (!url) {
    throw "No url given! Please provide an url."
  }
  const dialog = new Dialog(url, options)
  dialog.open()
}
