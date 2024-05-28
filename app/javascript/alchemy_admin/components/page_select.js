import { RemoteSelect } from "alchemy_admin/components/remote_select"

class PageSelect extends RemoteSelect {
  get pageId() {
    return this.selection ? JSON.parse(this.selection)["id"] : undefined
  }

  _searchQuery(term, page) {
    return {
      q: {
        name_cont: term,
        ...JSON.parse(this.queryParams)
      },
      page: page
    }
  }

  _parseResponse(response) {
    const meta = response.meta
    return {
      results: response.pages,
      more: meta.page * meta.per_page < meta.total_count
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
   * @param {string} term
   * @returns {string}
   * @private
   */
  _renderListEntry(page, term) {
    return `
      <div class="page-select--page">
        <div class="page-select--top">
          <alchemy-icon name="file-3"></alchemy-icon>
          <span class="page-select--page-name">${this._hightlightTerm(page.name, term)}</span>
          <span class="page-select--site-name">${page.site.name}</span>
        </div>
        <div class="page-select--bottom">
          <span class="page-select--page-urlname">${page.url_path}</span>
          <span class="page-select--language-code">${page.language_code}</span>
        </div>
      </div>
    `
  }
}

customElements.define("alchemy-page-select", PageSelect)
