import { AlchemyHTMLElement } from "alchemy_admin/components/alchemy_html_element"
import { setupSelectLocale } from "alchemy_admin/i18n"

export class RemoteSelect extends AlchemyHTMLElement {
  static properties = {
    allowClear: { default: false },
    selection: { default: undefined },
    placeholder: { default: "" },
    queryParams: { default: "{}" },
    url: { default: "" }
  }

  async connected() {
    await setupSelectLocale()

    this.input.classList.add("alchemy_selectbox")

    $(this.input)
      .select2(this.select2Config)
      .on("select2-open", (evt) => {
        this.onOpen(evt)
      })
      .on("change", (evt) => {
        this.onChange(evt)
      })
  }

  /**
   * Optional on change handler called by Select2.
   * @param {Event} event
   */
  onChange(event) {
    this.dispatchCustomEvent("RemoteSelect.Change", {
      removed: event.removed,
      added: event.added
    })
  }

  /**
   * Optional on open handler called by Select2.
   * @param {Event} event
   */
  onOpen(event) {
    // add focus to the search input. Select2 is handling the focus on the first opening,
    // but it does not work the second time. One process in select2 is "stealing" the focus
    // if the command is not delayed. It is an intermediate solution until we are going to
    // move away from Select2
    setTimeout(() => {
      document.querySelector("#select2-drop .select2-input").focus()
    }, 100)
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
      formatSelection: (item) => this._renderResult(item),
      formatResult: (item, _el, query) =>
        this._renderListEntry(item, query.term)
    }
  }

  /**
   * Ajax configuration for Select2
   * @returns {object}
   */
  get ajaxConfig() {
    return {
      url: this.url,
      datatype: "json",
      quietMillis: 300,
      data: (term, page) => this._searchQuery(term, page),
      results: (response) => this._parseResponse(response)
    }
  }

  /**
   * Search query send to server from select2
   * @param {string} term
   * @param {number} page
   * @returns {object}
   * @private
   */
  _searchQuery(term, page) {
    return {
      q: {
        name_cont: term,
        ...JSON.parse(this.queryParams)
      },
      page: page
    }
  }

  /**
   * Parses server response into select2 results object
   * @param {object} response
   * @returns {object}
   * @private
   */
  _parseResponse(response) {
    const meta = response.meta
    return {
      results: response.data,
      more: meta.page * meta.per_page < meta.total_count
    }
  }

  /**
   * result which is visible if a page was selected
   * @param {object} item
   * @returns {string}
   * @private
   */
  _renderResult() {
    throw new Error(
      "You need to define a _renderResult function on your sub class!"
    )
  }

  /**
   * html template for each list entry
   * @param {object} item
   * @param {string} term
   * @returns {string}
   * @private
   */
  _renderListEntry() {
    throw new Error(
      "You need to define a _renderListEntry function on your sub class!"
    )
  }

  /**
   * hightlighted search term
   * @param {string} name
   * @param {string} term
   * @returns {string}
   * @private
   */
  _hightlightTerm(name, term) {
    return name.replace(new RegExp(term, "gi"), (match) => `<em>${match}</em>`)
  }
}
