// The admin sitemap Alchemy class

export default class Sitemap {
  // Storing some objects.
  constructor(options) {
    const list_template_regexp = new RegExp("/" + options.page_root_id, "g")
    const list_template_html = document
      .getElementById("sitemap-list")
      .innerHTML.replace(list_template_regexp, "/{{id}}")
    this.search_field = document.querySelector(".search_input_field")
    this.filter_field_clear = document.querySelector(".search_field_clear")
    this.filter_field_clear.removeAttribute("href")
    this.display = document.getElementById("page_filter_result")
    this.sitemap_wrapper = document.getElementById("sitemap-wrapper")
    this.template = Handlebars.compile(
      document.getElementById("sitemap-template").innerHTML
    )
    this.list_template = Handlebars.compile(list_template_html)
    this.items = null
    this.options = options
    Handlebars.registerPartial("list", list_template_html)
    this.load(options.page_root_id)
  }

  // Loads the sitemap
  load(pageId) {
    const spinner = this.options.spinner || new Alchemy.Spinner("medium")
    const spinTarget = this.sitemap_wrapper
    spinTarget.innerHTML = ""
    spinner.spin(spinTarget)
    this.fetch(
      `${this.options.url}?id=${pageId}&full=${this.options.full}`
    ).then(async (response) => {
      this.render(await response.json())
      spinner.stop()
    })
  }

  // Reload the sitemap for a specific branch
  reload(pageId) {
    const spinner = new Alchemy.Spinner("small")
    const spinTarget = document.getElementById(`fold_button_${pageId}`)
    spinTarget.querySelector(".far").remove()
    spinner.spin(spinTarget)
    this.fetch(`${this.options.url}?id=${pageId}`).then(async (response) => {
      this.render(await response.json(), pageId)
      spinner.stop()
    })
  }

  fetch(url) {
    return fetch(url).catch((error) => console.warn(`Request failed: ${error}`))
  }

  // Renders the sitemap
  render(data, foldingId) {
    let renderTarget, renderTemplate

    if (foldingId) {
      renderTarget = document.getElementById(`page_${foldingId}`)
      renderTemplate = this.list_template
      renderTarget.outerHTML = renderTemplate({ children: data.pages })
    } else {
      renderTarget = this.sitemap_wrapper
      renderTemplate = this.template
      renderTarget.innerHTML = renderTemplate({ children: data.pages })
    }
    this.items = document
      .getElementById("sitemap")
      .querySelectorAll(".sitemap_page")
    this.sitemap_wrapper = document.getElementById("sitemap-wrapper")
    this._observe()

    if (this.options.ready) {
      this.options.ready()
    }
  }

  // Filters the sitemap
  filter(term) {
    const results = []

    this.items.forEach(function (item) {
      if (
        term !== "" &&
        item.getAttribute("name").toLowerCase().indexOf(term) !== -1
      ) {
        item.classList.add("highlight")
        item.classList.remove("no-match")
        results.push(item)
      } else {
        item.classList.add("no-match")
        item.classList.remove("highlight")
      }
    })
    this.filter_field_clear.style.display = "inline-block"
    const { length } = results

    if (length === 1) {
      this.display.style.display = "block"
      this.display.innerText = `1 ${Alchemy.t("page_found")}`
      results[0].scrollIntoView({ behavior: "smooth", block: "center" })
    } else if (length > 1) {
      this.display.style.display = "block"
      this.display.innerText = `${length} ${Alchemy.t("pages_found")}`
    } else {
      this.items.forEach((item) =>
        item.classList.remove("no-match", "highlight")
      )
      this.display.style.display = "none"
      window.scrollTo({
        top: 0,
        left: 0,
        behavior: "smooth"
      })
      this.filter_field_clear.style.display = "none"
    }
  }

  // Adds onkey up observer to search field
  _observe() {
    this.search_field.addEventListener("keyup", (evt) => {
      const term = evt.target.value
      this.filter(term.toLowerCase())
    })
    this.search_field.addEventListener("focus", () => key.setScope("search"))
    this.filter_field_clear.addEventListener("click", () => {
      this.search_field.value = ""
      this.filter("")
      return false
    })
  }
}
