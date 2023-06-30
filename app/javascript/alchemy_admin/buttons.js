function observe(scope) {
  return $("form", scope)
    .not(".button_with_label form")
    .on("submit", function (event) {
      var $btn, $form, $outside_button
      $form = $(this)
      $btn = $form.find(":submit")
      $outside_button = $(
        '[data-alchemy-button][form="' + $form.attr("id") + '"]'
      )
      if (
        $btn.attr("disabled") === "disabled" ||
        $outside_button.attr("disabled") === "disabled"
      ) {
        event.preventDefault()
        event.stopPropagation()
        return false
      } else {
        Alchemy.Buttons.disable($btn)
        if ($outside_button) {
          Alchemy.Buttons.disable($outside_button)
        }
        return true
      }
    })
}

function disable(button) {
  var $button, spinner
  $button = $(button)
  spinner = new Alchemy.Spinner("small")
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
  return true
}

function enable(scope) {
  var $buttons
  $buttons = $("form :submit:disabled, [data-alchemy-button].disabled", scope)
  $.each($buttons, function () {
    var $button
    $button = $(this)
    $button.removeClass("disabled")
    $button.removeAttr("disabled")
    $button.removeAttr("tabindex")
    $button.css("width", "")
    $button.css("height", "")
    return $button.html($button.data("content"))
  })
  return true
}

export default {
  observe,
  disable,
  enable
}
