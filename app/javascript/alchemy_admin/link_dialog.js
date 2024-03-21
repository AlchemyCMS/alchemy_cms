// Represents the link Dialog that appears, if a user clicks the link buttons
// in TinyMCE or on an Ingredient that has links enabled (e.g. Picture)
//
export class LinkDialog extends Alchemy.Dialog {
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
      title: "Link"
    })
  }

  /**
   *  Called from Dialog class after the url was loaded
   */
  replace(data) {
    // let Dialog class handle the content replacement
    super.replace(data)
    // Store some jQuery objects for further reference
    this.$internal_link = $("#internal_link", this.dialog_body)
    this.$element_anchor = $("#element_anchor", this.dialog_body)
    this.linkForm = document.querySelector('[data-link-form-type="internal"]')

    // attach events we handle
    this.attachEvents()
  }

  /**
   * make the open method a promise
   * maybe in a future version the whole Dialog will respond with a promise result if the dialog is closing
   * @returns {Promise<unknown>}
   */
  open() {
    super.open(...arguments)
    return new Promise((resolve) => (this.resolve = resolve))
  }

  updatePage(page) {
    this.$internal_link.val(page != null ? page.url_path : undefined)(
      (this.linkForm.querySelector("alchemy-anchor-select").page =
        page != null ? page.id : undefined)
    )
  }

  // Attaches click events to forms in the link dialog.
  attachEvents() {
    // enable the dom selection in internal link tab
    this.linkForm.addEventListener("Alchemy.PageSelect.ItemRemoved", (e) =>
      this.updatePage()
    )
    this.linkForm.addEventListener("Alchemy.PageSelect.ItemAdded", (e) =>
      this.updatePage(e.detail)
    )

    $("[data-link-form-type]", this.dialog_body).on("submit", (e) => {
      e.preventDefault()
      this.link_type = e.target.dataset.linkFormType
      // get url and remove a possible hash fragment
      let url = $(`#${this.link_type}_link`).val().replace(/#\w+$/, "")
      if (this.link_type === "internal" && this.$element_anchor.val() !== "") {
        url += "#" + this.$element_anchor.val()
      }

      // Create the link
      this.createLink({
        url,
        title: $(`#${this.link_type}_link_title`).val(),
        target: $(`#${this.link_type}_link_target`).val()
      })
    })
  }

  // Creates a link if no validation errors are present.
  // Otherwise shows an error notice.
  createLink(options) {
    if (
      this.link_type === "external" &&
      !options.url.match(Alchemy.link_url_regexp)
    ) {
      this.showValidationError()
    } else {
      this.setLink(options)
      this.close()
    }
  }

  // Sets the link either in TinyMCE or on an Ingredient.
  setLink(options) {
    this.resolve({
      url: options.url.trim(),
      title: options.title,
      target: options.target,
      type: this.link_type
    })
  }

  // Shows validation errors
  showValidationError() {
    $("#errors ul", this.dialog_body).html(
      `<li>${Alchemy.t("url_validation_failed")}</li>`
    )
    return $("#errors", this.dialog_body).show()
  }
}
