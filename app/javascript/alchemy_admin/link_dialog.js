import { translate } from "alchemy_admin/i18n"

// Represents the link Dialog that appears, if a user clicks the link buttons
// in TinyMCE or on an Ingredient that has links enabled (e.g. Picture)
//
export class LinkDialog extends Alchemy.Dialog {
  #onCreateLink

  constructor(link) {
    const url = new URL(Alchemy.routes.link_admin_pages_path, window.location)
    const parameterMapping = {
      url: link.url,
      selected_tab: link.type,
      link_title: link.title,
      link_target: link.target
    }

    // searchParams.set would also add undefined values
    Object.keys(parameterMapping).forEach((key) => {
      if (parameterMapping[key]) {
        url.searchParams.set(key, parameterMapping[key])
      }
    })

    super(url.href, {
      size: "600x320",
      title: translate("Link")
    })
  }

  /**
   *  Called from Dialog class after the url was loaded
   */
  replace(data) {
    // let Dialog class handle the content replacement
    super.replace(data)
    this.#attachEvents()
  }

  /**
   * make the open method a promise
   * maybe in a future version the whole Dialog will respond with a promise result if the dialog is closing
   * @returns {Promise<unknown>}
   */
  open() {
    super.open()
    return new Promise((resolve) => (this.#onCreateLink = resolve))
  }

  /**
   * Attaches click events to forms in the link dialog.
   */
  #attachEvents() {
    // enable the dom selection in internal link tab
    const internalForm = document.querySelector(
      '[data-link-form-type="internal"]'
    )

    internalForm.addEventListener("Alchemy.RemoteSelect.Change", (e) => {
      this.#updatePage(e.detail.added)
    })

    document.querySelectorAll("[data-link-form-type]").forEach((form) => {
      form.addEventListener("submit", (e) => {
        e.preventDefault()
        this.#submitForm(e.target.dataset.linkFormType)
      })
    })
  }

  /**
   * update page select and set anchor select
   * @param page
   */
  #updatePage(page = null) {
    const internalLink = document.getElementById("internal_link")
    const domIdSelect = document.querySelector(
      '[data-link-form-type="internal"] alchemy-dom-id-api-select'
    )

    internalLink.value = page != null ? page.url_path : undefined
    domIdSelect.page = page != null ? page.id : undefined
  }

  /**
   * submit the form itself
   * @param linkType
   */
  #submitForm(linkType) {
    const elementAnchor = document.getElementById("element_anchor")
    let url = document.getElementById(`${linkType}_link`).value

    if (linkType === "internal" && elementAnchor.value !== "") {
      // remove possible fragments on the url and attach the fragment (which contains the #)
      url = url.replace(/#\w+$/, "") + elementAnchor.value
    } else if (linkType === "external" && !url.match(Alchemy.link_url_regexp)) {
      // show validation error and prevent link creation
      this.#showValidationError()
      return
    }

    // Create the link
    this.#onCreateLink({
      url: url.trim(),
      title: document.getElementById(`${linkType}_link_title`).value,
      target: document.getElementById(`${linkType}_link_target`)?.value,
      type: linkType
    })
    this.close()
  }

  /**
   * Shows validation errors
   */
  #showValidationError() {
    const errors = document.getElementById("errors")
    errors.querySelector("ul").innerHTML =
      `<li>${Alchemy.t("url_validation_failed")}</li>`
    errors.style.display = "block"
  }
}
