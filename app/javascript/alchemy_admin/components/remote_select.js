import TomSelect from "tom-select"
import { translate } from "alchemy_admin/i18n"
import {
  createDropdownPositioning,
  dropdownMessages
} from "alchemy_admin/utils/tom_select"

export function hightlightTerm(name, term) {
  if (!term) return name
  return name.replace(new RegExp(term, "gi"), (match) => `<em>${match}</em>`)
}

/**
 * Serializes a (possibly nested) params object into a Rails/Ransack style query
 * string, e.g. `{ q: { name_cont: "x" }, page: 1 }` => `q%5Bname_cont%5D=x&page=1`.
 * @param {object} params
 * @param {string} [prefix]
 * @returns {string}
 */
export function serializeParams(params, prefix) {
  return Object.keys(params)
    .map((key) => {
      const value = params[key]
      const scopedKey = prefix ? `${prefix}[${key}]` : key
      if (value === null || value === undefined) return ""
      if (Array.isArray(value)) {
        return value
          .map(
            (item) =>
              `${encodeURIComponent(`${scopedKey}[]`)}=${encodeURIComponent(item)}`
          )
          .join("&")
      }
      if (typeof value === "object") {
        return serializeParams(value, scopedKey)
      }
      return `${encodeURIComponent(scopedKey)}=${encodeURIComponent(value)}`
    })
    .filter((part) => part !== "")
    .join("&")
}

export class RemoteSelect extends HTMLElement {
  #tomSelect = null
  // The currently selected item, used to compute the added/removed delta that
  // consumers of the RemoteSelect.Change event rely on.
  #selectedItem = null

  connectedCallback() {
    this.input.classList.add("alchemy_selectbox")
    // Preselection is driven by the `selection` attribute, not by the input's
    // value. Clear the value during setup so Tom Select does not turn it into a
    // stray option and does not overwrite it with the selected id — the link
    // dialog renders a URL in this input and reads it back. Restore it afterwards.
    const inputValue = this.input.value
    this.input.value = ""
    this.#tomSelect = new TomSelect(this.input, this.tomSelectConfig)
    this.input.value = inputValue
    // A spinner shown inside the control while results load. Tom Select toggles
    // the wrapper's `loading` class, which reveals it (see the stylesheet).
    this.#tomSelect.control.append(document.createElement("sl-spinner"))
  }

  disconnectedCallback() {
    this.#tomSelect?.destroy()
    this.#tomSelect = null
  }

  /**
   * Optional on change handler.
   * @param {{added: ?object, removed: ?object}} event
   */
  onChange(event) {
    // Update selection attribute so re-attaching the component to the same
    // input (e.g. after dragndrop) does not reset the selection.
    if (event.added) {
      this.setAttribute("selection", JSON.stringify(event.added))
    }
    this.dispatchCustomEvent("RemoteSelect.Change", {
      removed: event.removed,
      added: event.added
    })
  }

  /**
   * Optional on open handler, called when the dropdown opens.
   * @param {Event} [event]
   */
  onOpen() {}

  /**
   * Dispatches a custom event with given name, namespaced under `Alchemy.`.
   * Subclasses may call this to emit their own events.
   * @param {string} name The name of the custom event
   * @param {object} detail Optional event details
   */
  dispatchCustomEvent(name, detail = {}) {
    this.dispatchEvent(
      new CustomEvent(`Alchemy.${name}`, { bubbles: true, detail })
    )
  }

  get allowClear() {
    return this.hasAttribute("allow-clear")
  }

  get selection() {
    return this.getAttribute("selection")
  }

  get placeholder() {
    return this.getAttribute("placeholder") ?? ""
  }

  get queryParams() {
    return this.getAttribute("query-params") ?? "{}"
  }

  get url() {
    return this.getAttribute("url") ?? ""
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }

  /**
   * Tom Select configuration.
   * @returns {object}
   */
  get tomSelectConfig() {
    const self = this
    const ajax = this.ajaxConfig
    const plugins = { virtual_scroll: {} }

    if (this.allowClear) {
      plugins.clear_button = {
        html() {
          return `<button type="button" class="clear-button" aria-label="${translate(
            "Clear selection"
          )}">
            <alchemy-icon name="close" size="1x"></alchemy-icon>
          </button>`
        }
      }
    }

    const { onDropdownOpen, onDropdownClose } = createDropdownPositioning()

    return {
      plugins,
      // The server returns each item with an `id` used as the option value.
      valueField: "id",
      // Only a single item can be selected.
      maxItems: 1,
      // Close the dropdown after selecting, like a single native select.
      closeAfterSelect: true,
      // Show every item returned by the server, not just the first 50.
      maxOptions: null,
      // Searching is done on the server, so keep every returned option.
      searchField: [],
      // Debounce the server requests while typing.
      loadThrottle: ajax.quietMillis,
      // Refresh the input state (hide the selection, show the loading dropdown)
      // on every keystroke without delay. The server request stays debounced by
      // loadThrottle, so this only affects the immediate UI feedback.
      refreshThrottle: 0,
      placeholder: this.placeholder,
      // Load the first page of results as soon as the field is focused, so the
      // dropdown shows results without having to type first (like Select2 did).
      preload: "focus",
      // Load even for an empty search term to show the initial result list.
      shouldLoad: () => true,
      firstUrl: (query) => this.#requestUrl(query, 1),
      load: (query, callback) => this.#load(query, callback),
      onInitialize() {
        if (self.selection) {
          const item = JSON.parse(self.selection)
          // Track the preselected item first, so the change handler recognizes
          // it as unchanged and does not dispatch a spurious change event.
          self.#selectedItem = item
          // The preselection only carries enough data to label the item. Mark it,
          // so the option template can tell it apart from the complete records
          // the server returns. Loading the record drops the mark again.
          this.addOption({ ...item, $preselection: true })
          this.addItem(item.id)
        }
      },
      onChange(value) {
        self.#onChange(value, this)
      },
      onType(term) {
        // While typing, give the search input an opaque background so it covers
        // the selected item behind it. Without this the previous selection shows
        // through the search box (see the `input-active` styles).
        this.control_input.classList.toggle("has-value", term.length > 0)
      },
      onDropdownOpen() {
        onDropdownOpen.call(this)
        // The options still hold the results of the last search, and the initial
        // preload only ever runs once. Start over, so opening the dropdown shows
        // the first page again. Typing opens it too, but then a request is
        // already on its way and we must not discard it.
        if (!this.loading) {
          self.#reset(this)
          this.load(this.lastValue ?? "")
        }
        self.onOpen()
      },
      onDropdownClose() {
        this.control_input.classList.remove("has-value")
        onDropdownClose.call(this)
      },
      render: {
        option(item, _escape) {
          // A preselection that the server has not returned yet only carries
          // enough data to label the item, so render it like the control does.
          // Everything else is a complete record and gets the list entry.
          if (item.$preselection) {
            return `<div>${self._renderResult(item)}</div>`
          }
          return self._renderListEntry(item, this.lastValue)
        },
        item(item, _escape) {
          return `<div>${self._renderResult(item)}</div>`
        },
        ...dropdownMessages
      }
    }
  }

  /**
   * Ajax configuration. Kept for API compatibility with subclasses that spread
   * `super.ajaxConfig` and augment it (e.g. adding request `params`).
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
   * Builds the request url for a given search term and page.
   * @param {string} term
   * @param {number} page
   * @returns {string}
   * @private
   */
  #requestUrl(term, page) {
    const query = serializeParams(this.ajaxConfig.data(term, page))
    const separator = this.url.includes("?") ? "&" : "?"
    return query ? `${this.url}${separator}${query}` : this.url
  }

  /**
   * Forgets everything that was loaded, so the next request starts at the first
   * page again. The selected item keeps its value, only the option it was
   * rendered from is dropped, the server sends it again if it matches.
   * @param {TomSelect} tomSelect
   * @private
   */
  #reset(tomSelect) {
    tomSelect.clearOptions(() => false)
    tomSelect.clearPagination?.()
  }

  /**
   * Loads results from the server and registers the next page url for the
   * virtual scroll plugin.
   * @param {string} query
   * @param {function} callback
   * @private
   */
  async #load(query, callback) {
    const ajax = this.ajaxConfig
    const url = this.#tomSelect.getUrl(query)
    const page = Number(
      new URL(url, window.location.origin).searchParams.get("page")
    )
    // A fresh search (first page) must replace the previous results, not append
    // to them. The virtual_scroll plugin keeps the options preloaded for the
    // empty query as permanent "defaults" and never clears them, and the
    // selected item survives the default clearing, so a search without a match
    // would keep showing stale options instead of the no results message. Drop
    // them all, the server sends back whatever still matches.
    if (!page || page === 1) {
      this.#reset(this.#tomSelect)
    }
    try {
      const response = await fetch(url, {
        headers: { Accept: "application/json", ...(ajax.params?.headers ?? {}) }
      })
      const { results, more } = ajax.results(await response.json())
      if (more) {
        this.#tomSelect.setNextUrl(query, this.#requestUrl(query, page + 1))
      }
      // The dropdown is sorted by the order the options were added. A preselected
      // option was added before the request and would sort in front of the
      // results, so stamp the order the server returned onto every record. An
      // already known option keeps its own order otherwise.
      results.forEach((result) => {
        result.$order = ++this.#tomSelect.order
      })
      callback(results)
    } catch {
      callback()
    }
  }

  /**
   * Computes the added/removed delta from a Tom Select change and forwards it to
   * the `onChange` handler.
   * @param {string} value
   * @param {TomSelect} tomSelect
   * @private
   */
  #onChange(value, tomSelect) {
    const previous = this.#selectedItem
    if (value === "" || value == null) {
      if (!previous) return
      this.#selectedItem = null
      this.onChange({ added: null, removed: previous })
    } else if (!previous || String(previous.id) !== String(value)) {
      const added = tomSelect.options[value] ?? null
      this.#selectedItem = added
      this.onChange({ added, removed: previous })
    }
  }

  /**
   * Search query send to server.
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
   * Parses server response into a results object.
   * @param {object} response
   * @returns {{results: Array, more: boolean}}
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
   * result which is visible if an item was selected
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
    return hightlightTerm(name, term)
  }
}
