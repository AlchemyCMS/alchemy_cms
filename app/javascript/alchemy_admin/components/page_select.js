import { AlchemyHTMLElement } from "./alchemy_html_element"

class PageSelect extends AlchemyHTMLElement {
  static properties = {
    allowClear: { default: false },
    selection: { default: undefined },
    placeholder: { default: "" },
    queryParams: { default: "{}" },
    url: { default: "" }
  }

  connected() {
    this.input.classList.add("alchemy_selectbox")

    const dispatchCustomEvent = (name, detail = {}) => {
      this.dispatchEvent(new CustomEvent(name, { bubbles: true, detail }))
    }

    $(this.input)
      .select2(this.select2Config)
      .on("select2-open", (event) => {
        // add focus to the search input. Select2 is handling the focus on the first opening,
        // but it does not work the second time. One process in select2 is "stealing" the focus
        // if the command is not delayed. It is an intermediate solution until we are going to
        // move away from Select2
        setTimeout(() => {
          document.querySelector("#select2-drop .select2-input").focus()
        }, 100)
      })
      .on("change", (event) => {
        if (event.added) {
          dispatchCustomEvent("Alchemy.PageSelect.PageAdded", event.added)
        } else {
          dispatchCustomEvent("Alchemy.PageSelect.PageRemoved")
        }
      })
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }

  get select2Config() {
    return {
      placeholder: this.placeholder,
      allowClear: this.allowClear,
      initSelection: (_$el, callback) => {
        if (this.selection) {
          callback(JSON.parse(this.selection))
        }
      },
      ajax: this.ajaxConfig,
      formatSelection: this._renderResult,
      formatResult: this._renderListEntry
    }
  }

  /**
   * Ajax configuration for Select2
   * @returns {object}
   */
  get ajaxConfig() {
    const data = (term, page) => {
      return {
        q: { name_cont: term, ...JSON.parse(this.queryParams) },
        page: page
      }
    }

    const results = (data) => {
      const meta = data.meta
      return {
        results: data.pages,
        more: meta.page * meta.per_page < meta.total_count
      }
    }

    return {
      url: this.url,
      datatype: "json",
      quietMillis: 300,
      data,
      results
    }
  }

  /**
   * result which is visible if a page was selected
   * @param {object} page
   * @returns {string}
   * @private
   */
  _renderResult(page) {
    return page.text || page.name
  }

  /**
   * html template for each list entry
   * @param {object} page
   * @returns {string}
   * @private
   */
  _renderListEntry(page) {
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
}

customElements.define("alchemy-page-select", PageSelect)
