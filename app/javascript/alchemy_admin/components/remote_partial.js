import { translate } from "alchemy_admin/i18n"

/**
 * the remote partial will automatically load the content of the given url and
 * put the fetched content into the inner component. It also handles different
 * kinds of error cases.
 */
class RemotePartial extends HTMLElement {
  constructor() {
    super()
    this.addEventListener("ajax:success", this)
    this.addEventListener("ajax:error", this)
  }

  /**
   * handle the ajax event from inner forms
   * this is an intermediate solution until we moved away from jQuery
   * @param {CustomEvent} event
   * @deprecated
   */
  handleEvent(event) {
    /** @type {String} status */
    const status = event.detail[1]
    /** @type {XMLHttpRequest} xhr */
    const xhr = event.detail[2]

    switch (event.type) {
      case "ajax:success":
        const isTextResponse = xhr
          .getResponseHeader("Content-Type")
          .match(/html/)

        if (isTextResponse) {
          this.innerHTML = xhr.responseText
        }
        break
      case "ajax:error":
        this.#showErrorMessage(status, xhr.responseText, "error")
        break
    }
  }

  /**
   * show the spinner and load the content
   * after the content is loaded the spinner will be replaced by the fetched content
   */
  connectedCallback() {
    this.innerHTML = `<alchemy-spinner size="medium"></alchemy-spinner>`

    fetch(this.url, {
      headers: { "X-Requested-With": "XMLHttpRequest" }
    })
      .then(async (response) => {
        if (response.ok && !response.redirected) {
          this.innerHTML = await response.text()
        } else if (response.ok && response.redirected) {
          this.#showErrorMessage(
            translate("You are not authorized!"),
            translate("Please close this window.")
          )
        } else {
          this.#showErrorMessage(
            response.statusText,
            await response.text(),
            "error"
          )
        }
      })
      .catch(() => {
        this.#showErrorMessage(
          translate("The server does not respond."),
          translate("Please check server and try again.")
        )
      })
  }

  /**
   * @param {string} title
   * @param {string} description
   * @param {"warning"|"error"} type
   */
  #showErrorMessage(title, description, type = "warning") {
    this.innerHTML = `
      <alchemy-message type="${type}">
        <h1>${title}</h1>
        <p>${description}</p>
      </alchemy-message>
    `
  }

  get url() {
    return this.getAttribute("url")
  }
}

customElements.define("alchemy-remote-partial", RemotePartial)
