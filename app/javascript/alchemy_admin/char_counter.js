export default function CharCounter(field) {
  const $field = $(field)
  const $display = $('<small class="alchemy-char-counter"/>')
  $field.after($display)

  const maxChar = $field.data("alchemy-char-counter")
  const translation = Alchemy.t("allowed_chars", maxChar)

  function countChars() {
    const charLength = $field.val().length

    $display.removeClass("too-long")
    $display.text(`${charLength} ${translation}`)

    if (charLength > maxChar) {
      return $display.addClass("too-long")
    }
  }

  countChars()
  $field.keyup(countChars)
}
