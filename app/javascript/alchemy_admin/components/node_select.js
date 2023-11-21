import { AlchemyHTMLElement } from "./alchemy_html_element"

class NodeSelect extends AlchemyHTMLElement {
  static properties = {
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
      .on("select2-open", () => {
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
          dispatchCustomEvent("Alchemy.NodeSelect.NodeAdded", event.added)
        } else {
          dispatchCustomEvent("Alchemy.NodeSelect.NodeRemoved")
        }
      })
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }

  get select2Config() {
    return {
      placeholder: this.placeholder,
      allowClear: true,
      initSelection: (_$el, callback) => {
        if (this.selection) {
          callback(JSON.parse(this.selection))
        }
      },
      ajax: this.ajaxConfig,
      formatSelection: this._renderListEntry,
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
        q: {
          name_or_page_name_cont: term,
          ...JSON.parse(this.queryParams)
        },
        page: page
      }
    }

    const results = (response) => {
      const meta = response.meta
      return {
        results: response.data,
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
   * html template for each list entry
   * @param {object} node
   * @returns {string}
   * @private
   */
  _renderListEntry(node) {
    const ancestors = node.ancestors.map((a) => a.name)
    return `
      <div class="node-select--node">
        <i class="icon fas fa-list fa-lg"></i>
        <div class="node-select--node-display_name">
          <span class="node-select--node-ancestors">
            ${ancestors.join(" /&nbsp;")}
          </span>
          <span class="node-select--node-name">
            ${node.name}
          </span>
        </div>
        <div class="node-select--node-url">
          ${node.url || ""}
        </div>
      </div>
    `
  }
}

customElements.define("alchemy-node-select", NodeSelect)
