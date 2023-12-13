import { RemoteSelect } from "alchemy_admin/components/remote_select"

class PageSelect extends RemoteSelect {
  onChange(event) {
    if (event.added) {
      this.dispatchCustomEvent("PageSelect.ItemAdded", event.added)
    } else {
      this.dispatchCustomEvent("PageSelect.ItemRemoved")
    }
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
   * @returns {string}
   * @private
   */
  _renderListEntry(page) {
    return `
      <div class="page-select--page">
        <div class="page-select--top">
          <i class="icon ri-file-3-line"></i>
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
