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

function Initialize() {
  // We obviously have javascript enabled.
  $("html").removeClass("no-js")

  // Initialize the GUI.
  Alchemy.GUI.init()

  // Fade all growl notifications.
  if ($("#flash_notices").length > 0) {
    Alchemy.Growler.fade()
  }

  // Add observer for please wait overlay.
  $(".please_wait, .button_with_label form :submit")
    .not("*[data-alchemy-confirm]")
    .click(Alchemy.pleaseWaitOverlay)

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

export default Initialize
