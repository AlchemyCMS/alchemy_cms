function change_parameter(name, id) {
  let url = window.location.pathname
  let delimiter = url.match(/\?/) ? "&" : "?"
  Turbo.visit(`${url}${delimiter}${name}=${id}`, {})
}

function initialize() {
  $("html").removeClass("no-js")
  Alchemy.GUI.init()

  if ($("#flash_notices").length > 0) {
    Alchemy.Growler.fade()
  }

  $(".please_wait, .button_with_label form :submit")
    .not("*[data-alchemy-confirm]")
    .click(Alchemy.pleaseWaitOverlay)
  $("a.button").attr({
    tabindex: 0
  })

  $("select#change_locale").on("change", function (e) {
    change_parameter("admin_locale", $(this).val())
  })

  $("select#change_site").on("change", function (e) {
    change_parameter("site_id", $(this).val())
  })

  $('select[data-auto-submit="true"]').on("change", function (e) {
    return $(this.form).submit()
  })

  Alchemy.ImageLoader("#main_content")
  key.filter = function (event) {
    let tagName = (event.target || event.srcElement).tagName
    return (
      key.isPressed("esc") ||
      !(tagName === "INPUT" || tagName === "SELECT" || tagName === "TEXTAREA")
    )
  }
}

export default initialize
