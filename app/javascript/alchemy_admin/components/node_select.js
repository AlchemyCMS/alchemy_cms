import { RemoteSelect } from "alchemy_admin/components/remote_select"

class NodeSelect extends RemoteSelect {
  _searchQuery(term, page) {
    return {
      filter: {
        name_or_page_name_cont: term,
        ...JSON.parse(this.queryParams)
      },
      page: page
    }
  }

  _renderResult(item) {
    return this._renderListEntry(item)
  }

  /**
   * html template for each list entry
   * @param {object} node
   * @param {string} term
   * @returns {string}
   * @private
   */
  _renderListEntry(node, term) {
    const ancestors = node.ancestors.map((a) => a.name)
    const seperator = `<alchemy-icon name="arrow-right-s"></alchemy-icon>`

    return `
      <div class="node-select--node">
        <alchemy-icon name="menu-2"></alchemy-icon>
        <div class="node-select--node-display_name">
          <span class="node-select--node-ancestors">
            ${ancestors.length > 0 ? ancestors.join(seperator) + seperator : ""}
          </span>
          <span class="node-select--node-name">
            ${this._hightlightTerm(node.name, term)}
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
