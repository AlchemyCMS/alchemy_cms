import { RemoteSelect } from "alchemy_admin/components/remote_select"

export class PageSelect extends RemoteSelect {
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

  _entry(page, term) {
    return {
      icon: "file-3",
      primary: this._hightlightTerm(page.name, term),
      aside: page.site?.name,
      secondary: { text: page.url_path, truncate: "head" },
      secondaryAside: { badge: page.language_code }
    }
  }

  _selectedEntry(page) {
    return {
      icon: "file-3",
      primary: page.text || page.name,
      secondary: { text: page.url_path, truncate: "head" }
    }
  }
}

customElements.define("alchemy-page-select", PageSelect)
