import { AlchemyHTMLElement } from "./alchemy_html_element"

class PageSelect extends AlchemyHTMLElement {
  static properties = {
    allow_clear: { default: true },
    selection: { default: {} },
    placeholder: { default: "" },
    query_params: { default: {} },
    url: { default: "" }
  }

  connected() {
    this.input.className = "alchemy_selectbox"
    $(this.input).select2({
      placeholder: this.placeholder,
      allowClear: this.allow_clear,

      initSelection: (_$el, callback) => {
        if (this.selection) {
          callback(JSON.parse(this.selection))
        }
      },
      ajax: {
        url: this.url,
        datatype: "json",
        quietMillis: 300,
        data: function (term, page) {
          return {
            q: { name_cont: term, ...this.query_params },
            page: page
          }
        },
        results: function (data) {
          const meta = data.meta

          return {
            results: data.pages,
            more: meta.page * meta.per_page < meta.total_count
          }
        }
      },
      formatSelection: function (page) {
        console.log("formatSelection")
        return page.text || page.name
      },
      formatResult: function (page) {
        return `
          <div class="page-select--page">
            <div class="page-select--top">
              <i class="icon far fa-file fa-lg"></i>
              <span class="page-select--page-name">${page.name}</span>
              <span class="page-select--page-urlname">${page.url_path}</span>
            </div>
            <div class="page-select--bottom">
              <span class="page-select--site-name">${page.site.name}</span>
              <span class="page-select--language-code">${page.language.name}</span>
            </div>
          </div>
        `
      }
    })
  }

  render() {
    return this.initialContent
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }
}

customElements.define("alchemy-page-select", PageSelect)
