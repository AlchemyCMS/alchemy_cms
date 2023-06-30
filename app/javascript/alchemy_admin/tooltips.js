export default function Tooltips(scope) {
  $("[data-alchemy-tooltip]", scope).each(function () {
    const $el = $(this)
    const text = $el.data("alchemy-tooltip")
    $el.wrap('<span class="with-hint"/>')
    $el.after('<span class="hint-bubble">' + text + "</span>")
  })
}
