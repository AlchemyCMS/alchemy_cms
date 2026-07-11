import {
  RemoteSelect,
  escapeHtml
} from "alchemy_admin/components/remote_select"

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

  _entry(node, term) {
    return {
      icon: "menu-2",
      primary: this.#breadcrumb(node) + this._hightlightTerm(node.name, term),
      secondary: { text: node.url, truncate: "head" }
    }
  }

  _selectedEntry(node) {
    return {
      icon: "menu-2",
      primary: this.#breadcrumb(node) + escapeHtml(node.name)
    }
  }

  /**
   * Renders the node's ancestors as a breadcrumb that precedes its name. The
   * ancestors place the node in the tree, so a deeply nested node reads clearly.
   * @param {object} node
   * @returns {string}
   */
  #breadcrumb(node) {
    const ancestors = node.ancestors.map((ancestor) => ancestor.name)
    if (ancestors.length === 0) return ""
    const separator = `<alchemy-icon name="arrow-right-s" class="node-select--separator"></alchemy-icon>`
    return `<span class="node-select--ancestors">${ancestors
      .map(escapeHtml)
      .join(separator)}</span>${separator}`
  }
}

customElements.define("alchemy-node-select", NodeSelect)
