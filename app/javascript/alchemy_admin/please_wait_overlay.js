/**
 * To show the "Please wait" overlay.
 * Pass false to hide it.
 * @param {boolean,null} show
 */
export default function pleaseWaitOverlay(show) {
  if (show == null) {
    show = true
  }
  const $overlay = $("#overlay")
  if (show) {
    const spinner = new Alchemy.Spinner("medium")
    spinner.spin($overlay)
    $overlay.show()
  } else {
    $overlay.find(".spinner").remove()
    $overlay.hide()
  }
}
