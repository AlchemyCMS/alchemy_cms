import { createHtmlElement } from "alchemy_admin/utils/dom_helpers"

function build(message, flashType) {
  const notices = document.getElementById("flash_notices")
  const flashContainer = createHtmlElement(
    `<div class="flash ${flashType}"></div>`
  )
  const icon = createHtmlElement(Alchemy.messageIcon(flashType))
  flashContainer.append(icon)
  if (flashType === "error") {
    const closeButton = createHtmlElement(
      '<alchemy-icon name="close"></alchemy-icon>'
    )
    flashContainer.append(closeButton)
  }
  flashContainer.append(message)
  notices.append(flashContainer)
  flashContainer.addEventListener("click", () => dismiss(flashContainer))

  fade()
}

function dismiss(element) {
  element.addEventListener("transitionend", () => element.remove())
  element.classList.add("dismissed")
}

export function fade() {
  const notices = document.getElementById("flash_notices")
  const flashNotices = notices.querySelectorAll(".flash:not(.error)")
  setTimeout(() => {
    flashNotices.forEach((notice) => dismiss(notice))
  }, 5000)
}

export function growl(message, style = "notice") {
  build(message, style)
}
