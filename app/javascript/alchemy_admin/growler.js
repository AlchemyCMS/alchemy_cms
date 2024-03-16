function build(message, flash_type) {
  const $flash_container = $(`<div class="flash ${flash_type}" />`)
  $flash_container.append(Alchemy.messageIcon(flash_type))
  if (flash_type === "error") {
    $flash_container.append('<alchemy-icon name="close"></alchemy-icon>')
  }
  $flash_container.append(message)
  $("#flash_notices").append($flash_container)
  $("#flash_notices").show()
  $flash_container.on("click", () => dismiss($flash_container))

  fade()
}

function dismiss(element) {
  $(element).on("transitionend", () => $(element).remove())
  $(element).addClass("dismissed")
}

export function fade() {
  $(".flash:not(.error)", "#flash_notices")
    .delay(5000)
    .queue(function () {
      dismiss(this)
    })
}

export function growl(message, style = "notice") {
  build(message, style)
}
