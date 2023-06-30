// Collection of all current dialog instances
let currentDialogs = []

/**
 * Gets the last dialog instantiated, which is the current one.
 * @returns {*}
 */
function currentDialog() {
  const length = currentDialogs.length
  if (length === 0) {
    return
  }
  return currentDialogs[length - 1]
}

/**
 * Utility function to close the current Dialog
 *
 * You can pass a callback function, that gets triggered after the Dialog gets closed.
 * @param {function} callback
 */
function closeCurrentDialog(callback) {
  const dialog = currentDialog()
  if (dialog != null) {
    dialog.options.closed = callback
    dialog.close()
  }
}

/**
 * Utility function to open a new Dialog
 * @param {string} url
 * @param {object} options
 */
function openDialog(url, options) {
  if (!url) {
    throw "No url given! Please provide an url."
  }
  const dialog = new Alchemy.Dialog(url, options)
  dialog.open()
}

/**
 * Watches elements for Alchemy Dialogs
 *
 * Links having a data-alchemy-dialog or data-alchemy-confirm-delete
 * and input/buttons having a data-alchemy-confirm attribute get watched.
 *
 * You can pass a scope so that only elements inside this scope are queried.
 *
 * The href attribute of the link is the url for the overlay window.
 *
 * See Alchemy.Dialog for further options you can add to the data attribute
 * @param {string} scope
 */
function watchForDialogs(scope) {
  if (scope == null) {
    scope = "#alchemy"
  }
  $(scope).on(
    "click",
    "[data-alchemy-dialog]:not(.disabled)",
    function (event) {
      const $this = $(this)
      const url = $this.attr("href")
      const options = $this.data("alchemy-dialog")
      Alchemy.openDialog(url, options)
      event.preventDefault()
    }
  )

  $(scope).on("click", "[data-alchemy-confirm-delete]", function (event) {
    const $this = $(this)
    const options = $this.data("alchemy-confirm-delete")
    Alchemy.confirmToDeleteDialog($this.attr("href"), options)
    event.preventDefault()
  })

  $(scope).on("click", "[data-alchemy-confirm]", function (event) {
    const options = $(this).data("alchemy-confirm")
    Alchemy.openConfirmDialog(options.message, {
      ...options,
      on_ok: () => {
        Alchemy.pleaseWaitOverlay()
        this.form.submit()
      }
    })

    event.preventDefault()
  })
}

/**
 * Returns a FontAwesome icon for given message type
 * @param {string} messageType
 * @returns {string}
 */
function messageIcon(messageType) {
  let icon_class = messageType
  switch (messageType) {
    case "warning":
    case "warn":
    case "alert":
      icon_class = "exclamation"
      break
    case "notice":
      icon_class = "check"
      break
    case "error":
      icon_class = "bug"
  }
  return '<i class="icon fas fa-' + icon_class + ' fa-fw" />'
}

export default {
  currentDialogs,
  currentDialog,
  closeCurrentDialog,
  openDialog,
  watchForDialogs,
  messageIcon
}
