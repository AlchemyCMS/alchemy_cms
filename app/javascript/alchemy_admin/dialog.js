import Hotkeys from "alchemy_admin/hotkeys"
import Spinner from "alchemy_admin/spinner"

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
  // Arguments:
  //  - url: The url to load the content from via ajax
  //  - options: A object holding options
  //    - size: The maximum size of the Dialog
  //    - title: The title of the Dialog
  constructor(url, options = {}) {
    this.url = url
    this.options = { ...DEFAULTS, ...options }
    this.$document = $(document)
    this.$window = $(window)
    this.$body = $("body")
    const size = this.options.size.split("x")
    this.width = parseInt(size[0], 10)
    this.height = parseInt(size[1], 10)
    this.build()
    this.resize()
  }

  // Opens the Dialog and loads the content via ajax.
  open() {
    this.dialog.trigger("Alchemy.DialogOpen")
    this.bind_close_events()
    window.requestAnimationFrame(() => {
      this.dialog_container.addClass("open")
      if (this.overlay != null) {
        return this.overlay.addClass("open")
      }
    })
    this.$body.addClass("prevent-scrolling")
    currentDialogs.push(this)
    this.load()
  }

  // Closes the Dialog and removes it from the DOM
  close() {
    this.dialog.trigger("DialogClose.Alchemy")
    this.$document.off("keydown")
    this.dialog_container.removeClass("open")
    if (this.overlay != null) {
      this.overlay.removeClass("open")
    }
    this.$document.on(
      "webkitTransitionEnd transitionend oTransitionEnd",
      () => {
        this.$document.off("webkitTransitionEnd transitionend oTransitionEnd")
        this.dialog_container.remove()
        if (this.overlay != null) {
          this.overlay.remove()
        }
        this.$body.removeClass("prevent-scrolling")
        currentDialogs.pop(this)
        if (this.options.closed != null) {
          return this.options.closed()
        }
      }
    )
    return true
  }

  // Loads the content via ajax and replaces the Dialog body with server response.
  load() {
    this.show_spinner()
    $.get(this.url, (data) => {
      this.replace(data)
    }).fail((xhr) => {
      this.show_error(xhr)
    })
  }

  // Reloads the Dialog content
  reload() {
    this.dialog_body.empty()
    this.load()
  }

  // Replaces the dialog body with given content and initializes it.
  replace(data) {
    this.remove_spinner()
    this.dialog_body.hide()
    this.dialog_body.html(data)
    this.init()
    this.dialog[0].dispatchEvent(
      new CustomEvent("DialogReady.Alchemy", {
        bubbles: true,
        detail: {
          body: this.dialog_body[0]
        }
      })
    )
    if (this.options.ready != null) {
      this.options.ready(this.dialog_body)
    }
    this.dialog_body.show()
  }

  // Adds a spinner into Dialog body
  show_spinner() {
    this.spinner = new Spinner("medium")
    this.spinner.spin(this.dialog_body[0])
  }

  // Removes the spinner from Dialog body
  remove_spinner() {
    this.spinner.stop()
  }

  // Initializes the Dialog body
  init() {
    Hotkeys(this.dialog_body)
    this.watch_remote_forms()
  }

  // Watches ajax requests inside of dialog body and replaces the content accordingly
  watch_remote_forms() {
    const $form = $('[data-remote="true"]', this.dialog_body)

    $form.on("ajax:success", (event) => {
      const xhr = event.detail[2]
      const content_type = xhr.getResponseHeader("Content-Type")
      if (content_type.match(/javascript/)) {
        return
      } else {
        this.dialog_body.html(xhr.responseText)
        this.init()
      }
    })

    $form.on("ajax:error", (event) => {
      const statusText = event.detail[1]
      const xhr = event.detail[2]
      this.show_error(xhr, statusText)
    })
  }

  // Displays an error message
  show_error(xhr, statusText) {
    if (xhr.status === 422) {
      this.dialog_body.html(xhr.responseText)
      this.init()
      return
    }

    const { error_body, error_header, error_type } = this.error_messages(
      xhr,
      statusText
    )

    const $errorDiv = $(`<alchemy-message type="${error_type}">
      <h1>${error_header}</h1>
      <p>${error_body}</p>
    </alchemy-message>`)

    this.dialog_body.html($errorDiv)
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
  // - ESC Key
  bind_close_events() {
    this.close_button.on("click", () => {
      this.close()
    })
    this.dialog_container.addClass("closable").on("click", (e) => {
      if (e.target !== this.dialog_container.get(0)) {
        return true
      }
      this.close()
      return false
    })
    this.$document.keydown((e) => {
      if (e.which === 27) {
        this.close()
        return false
      } else {
        return true
      }
    })
  }

  // Builds the html structure of the Dialog
  build() {
    this.dialog_container = $('<div class="alchemy-dialog-container" />')
    this.dialog = $('<div class="alchemy-dialog" />')
    this.dialog_body = $('<div class="alchemy-dialog-body" />')
    this.dialog_header = $('<div class="alchemy-dialog-header" />')
    this.dialog_title = $('<div class="alchemy-dialog-title" />')
    this.close_button = $(
      '<button class="alchemy-dialog-close"><alchemy-icon name="close"></alchemy-icon></button>'
    )
    this.dialog_title.text(this.options.title)
    this.dialog_header.append(this.dialog_title)
    this.dialog_header.append(this.close_button)
    this.dialog.append(this.dialog_header)
    this.dialog.append(this.dialog_body)
    this.dialog_container.append(this.dialog)
    if (this.options.modal) {
      this.dialog.addClass("modal")
    }
    if (this.options.padding) {
      this.dialog_body.addClass("padded")
    }
    if (this.options.modal) {
      this.overlay = $('<div class="alchemy-dialog-overlay" />')
      this.$body.append(this.overlay)
    }
    this.$body.append(this.dialog_container)
  }

  // Sets the correct size of the dialog
  // It normalizes the given size, so that it never acceeds the window size.
  resize() {
    const { width, height } = this.getSize()

    this.dialog.css({
      width: width,
      "min-height": height,
      overflow: this.options.overflow
    })

    if (this.options.overflow === "hidden") {
      this.dialog_body.css({
        height: height,
        overflow: "auto"
      })
    } else {
      this.dialog_body.css({
        "min-height": height,
        overflow: "visible"
      })
    }
  }

  getSize() {
    const padding = this.options.padding ? 16 : 0
    const doc_width = this.$window.width()
    const doc_height = this.$window.height()

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
