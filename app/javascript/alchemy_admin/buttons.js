function observe(scope) {
  $("form", scope)
    .not(".button_with_label form")
    .on("submit", function (event) {
      const $form = $(this)
      const $btn = $form.find(":submit")
      const $outside_button = $(
        `[data-alchemy-button][form="${$form.attr("id")}"]`
      )

      const isDisabled =
        $btn.attr("disabled") === "disabled" ||
        $outside_button.attr("disabled") === "disabled"

      if (isDisabled) {
        event.preventDefault()
        event.stopPropagation()
      } else {
        disable($btn)
        if ($outside_button) {
          disable($outside_button)
        }
      }
    })
}

function disable(button) {
  const $button = $(button)
  const spinner = new Alchemy.Spinner("small")
  $button.data("content", $button.html())
  $button.attr("disabled", true)
  $button.attr("tabindex", "-1")
  $button.addClass("disabled")
  $button.css({
    width: $button.outerWidth(),
    height: $button.outerHeight()
  })
  $button.empty()
  spinner.spin($button)
}

function enable(scope) {
  const $buttons = $(
    "form :submit:disabled, [data-alchemy-button].disabled",
    scope
  )
  $.each($buttons, function () {
    const $button = $(this)
    $button.removeClass("disabled")
    $button.removeAttr("disabled")
    $button.removeAttr("tabindex")
    $button.css("width", "")
    $button.css("height", "")
    $button.html($button.data("content"))
  })
}

export default {
  observe,
  disable,
  enable
}
