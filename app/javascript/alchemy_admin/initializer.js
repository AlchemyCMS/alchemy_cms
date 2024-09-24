import {
  confirmToDeleteDialog,
  openConfirmDialog
} from "alchemy_admin/confirm_dialog"

import Hotkeys from "alchemy_admin/hotkeys"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

/**
 * add change listener to select to redirect the user after selecting another locale or site
 * @param {string} selectId
 * @param {string} parameterName
 * @param {boolean} forcedReload
 */
function selectHandler(selectId, parameterName, forcedReload = false) {
  $(`select#${selectId}`).on("change", function (e) {
    let url = window.location.pathname
    let delimiter = url.match(/\?/) ? "&" : "?"
    const location = `${url}${delimiter}${parameterName}=${$(this).val()}`

    if (forcedReload) {
      window.location.href = location
    } else {
      Turbo.visit(location, {})
    }
  })
}

// Watches elements for Alchemy Dialogs
//
// Links having a data-alchemy-confirm-delete
// and input/buttons having a data-alchemy-confirm attribute get watched.
//
// You can pass a scope so that only elements inside this scope are queried.
//
// The href attribute of the link is the url for the overlay window.
//
// See Dialog for further options you can add to the data attribute.
//
function watchForConfirmDialogs(scope) {
  if (scope == null) {
    scope = "#alchemy"
  }
  $(scope).on("click", "[data-alchemy-confirm-delete]", function (event) {
    const $this = $(this)
    const options = $this.data("alchemy-confirm-delete")
    confirmToDeleteDialog($this.attr("href"), options)
    event.preventDefault()
  })
  $(scope).on("click", "[data-alchemy-confirm]", function (event) {
    const options = $(this).data("alchemy-confirm")
    openConfirmDialog(
      options.message,
      $.extend(options, {
        ok_label: options.ok_label,
        cancel_label: options.cancel_label,
        on_ok: () => {
          pleaseWaitOverlay()
          this.form.submit()
        }
      })
    )
    event.preventDefault()
  })
}

export default function Initializer() {
  // We obviously have javascript enabled.
  $("html").removeClass("no-js")

  // Initialize hotkeys.
  Hotkeys()

  // Watch for click on confirm dialog links.
  watchForConfirmDialogs()

  // Add observer for please wait overlay.
  $(".please_wait")
    .not("*[data-alchemy-confirm]")
    .on("click", Alchemy.pleaseWaitOverlay)

  // Hack for enabling tab focus for <a>'s styled as button.
  $("a.button").attr({ tabindex: 0 })

  // Locale select handler
  selectHandler("change_locale", "admin_locale", true)

  // Site select handler
  selectHandler("change_site", "site_id")

  // Submit forms of selects with `data-autosubmit="true"`
  $('select[data-auto-submit="true"]').on("change", function () {
    $(this.form).submit()
  })

  // Attaches the image loader on all images
  Alchemy.ImageLoader("#main_content")

  // Override the filter of keymaster.js so we can blur the fields on esc key.
  key.filter = function (event) {
    let tagName = (event.target || event.srcElement).tagName
    return (
      key.isPressed("esc") ||
      !(tagName === "INPUT" || tagName === "SELECT" || tagName === "TEXTAREA")
    )
  }
}
