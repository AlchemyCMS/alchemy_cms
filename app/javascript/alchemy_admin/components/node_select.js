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
   * @returns {string}
   * @private
   */
  _renderListEntry(node) {
    const ancestors = node.ancestors.map((a) => a.name)
    return `
      <div class="node-select--node">
        <i class="icon ri-menu-2-line"></i>
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
