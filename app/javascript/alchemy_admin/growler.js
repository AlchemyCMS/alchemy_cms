import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

function build(message, flashType) {
  const flashNotices = document.getElementById("flash_notices")
  const flashMessage = createHtmlElement(`
    <alchemy-message type="${flashType}" dismissable>
      ${message}
    </alchemy-message>
  `)
  flashNotices.append(flashMessage)
}

export function growl(message, style = "notice") {
  build(message, style)
}
