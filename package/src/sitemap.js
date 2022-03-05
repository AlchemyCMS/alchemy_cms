// The admin sitemap Alchemy class

export default class Sitemap {
  // Storing some objects.
  constructor(options) {
    const list_template_regexp = new RegExp("/" + options.page_root_id, "g")
    const list_template_html = $("#sitemap-list")
      .html()
      .replace(list_template_regexp, "/{{id}}")
    this.search_field = $(".search_input_field")
    this.filter_field_clear = $(".search_field_clear")
    this.display = $("#page_filter_result")
    this.sitemap_wrapper = $("#sitemap-wrapper p.loading")
    this.template = Handlebars.compile($("#sitemap-template").html())
    this.list_template = Handlebars.compile(list_template_html)
    this.items = null
    this.options = options
    Handlebars.registerPartial("list", list_template_html)
    this.fetch()
  }

  // Fetches the sitemap from JSON
  fetch(foldingId) {
    const pageId = foldingId || this.options.page_root_id

    $.ajax({
      url: this.options.url,
      data: {
        id: pageId,
        full: this.options.full
      }
    })
      .done((data) => {
        this.render(data, foldingId)
      })
      .fail((_jqXHR, status) => console.warn("Request failed: " + status))
  }

  // Renders the sitemap
  render(data, foldingId) {
    let renderTarget, renderTemplate, spinner, spinTarget

    if (foldingId) {
      spinner = new Alchemy.Spinner("small")
      spinTarget = $("#fold_button_" + foldingId)
      renderTarget = $("#page_" + foldingId)
      renderTemplate = this.list_template
    } else {
      spinner = this.options.spinner || new Alchemy.Spinner("medium")
      spinTarget = this.sitemap_wrapper
      renderTarget = this.sitemap_wrapper
      renderTemplate = this.template
    }
    spinner.spin(spinTarget[0])
    // This will also remove the spinner
    renderTarget.replaceWith(renderTemplate({ children: data.pages }))
    this.items = $(".sitemap_page", "#sitemap")
    this._observe()

    if (this.options.ready) {
      this.options.ready()
    }
  }

  // Filters the sitemap
  filter(term) {
    const results = []

    this.items.map(function () {
      const item = $(this)

      if (term !== "" && item.attr("name").toLowerCase().indexOf(term) !== -1) {
        item.addClass("highlight")
        item.removeClass("no-match")
        results.push(item)
      } else {
        item.addClass("no-match")
        item.removeClass("highlight")
      }
    })
    this.filter_field_clear.show()
    const { length } = results

    if (length === 1) {
      this.display.show().text(`1 ${Alchemy.t("page_found")}`)
      $.scrollTo(results[0], { duration: 400, offset: -80 })
    } else if (length > 1) {
      this.display.show().text(`${length} ${Alchemy.t("pages_found")}`)
    } else {
      this.items.removeClass("no-match highlight")
      this.display.hide()
      $.scrollTo("0", 400)
      this.filter_field_clear.hide()
    }
  }

  // Adds onkey up observer to search field
  _observe() {
    this.search_field.on("keyup", (evt) => {
      const term = evt.target.value
      this.filter(term.toLowerCase())
    })
    this.search_field.on("focus", () => key.setScope("search"))
    this.filter_field_clear.click(() => {
      this.search_field.val("")
      this.filter("")
      return false
    })
  }

  // Handles the page publication date fields
  static watchPagePublicationState() {
    $(document).on("DialogReady.Alchemy", function (e, $dialog) {
      const $public_on_field = $("#page_public_on", $dialog)
      const $public_until_field = $("#page_public_until", $dialog)
      const $publication_date_fields = $(
        ".page-publication-date-fields",
        $dialog
      )

      return $("#page_public", $dialog).click(function () {
        const $checkbox = $(this)
        const now = new Date()

        if ($checkbox.is(":checked")) {
          $publication_date_fields.removeClass("hidden")
          $public_on_field[0]._flatpickr.setDate(now)
        } else {
          $publication_date_fields.addClass("hidden")
          $public_on_field.val("")
        }
        $public_until_field.val("")
      })
    })
  }
}
