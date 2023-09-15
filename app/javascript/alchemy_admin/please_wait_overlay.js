/**
 * To show the "Please wait" overlay.
 * Pass false to hide it.
 * @param {boolean,null} show
 */
export default function pleaseWaitOverlay(show) {
  customElements.get("alchemy-overlay").show = !!show
}
