// Dispatch a submit event on change of input or select elements
// contained in a form, so that Turbo can submit the form.
class AutoSubmit extends HTMLElement {
  connectedCallback() {
    // Still using jQuery here, because select2 does not emit
    // the event from the original select element.
    $(this).on("change", function (event) {
      // We need to dispatch a submit event, so that Turbo that listens
      // to it submits the search form us.
      const submitEvent = new Event("submit", {
        bubbles: true,
        cancelable: true
      })
      event.target.form.dispatchEvent(submitEvent)
      return false
    })
  }
}

customElements.define("alchemy-auto-submit", AutoSubmit)
