/**
 * To show the "Please wait" overlay.
 * Pass false to hide it.
 * @param {boolean} show
 */
export default function pleaseWaitOverlay(show = true) {
  document.querySelector("alchemy-overlay").show = !!show
}
