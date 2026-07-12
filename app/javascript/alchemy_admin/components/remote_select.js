import TomSelect from "tom-select"
import { translate } from "alchemy_admin/i18n"
import {
  createDropdownPositioning,
  dropdownMessages,
  focusTomSelect
} from "alchemy_admin/utils/tom_select"

export function hightlightTerm(name, term) {
  if (!term) return name
  return name.replace(new RegExp(term, "gi"), (match) => `<em>${match}</em>`)
}

/**
 * Escapes a value for safe interpolation as HTML text content.
 * @param {*} value
 * @returns {string}
 */
export function escapeHtml(value) {
  return String(value)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
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
    // Open the dropdown on click, mirroring the native <alchemy-select> (Tom
    // Select does not open on click on its own once openOnFocus is off).
    this.#tomSelect.control.addEventListener(
      "click",
      this.#tomSelect.open.bind(this.#tomSelect)
    )
  }

  disconnectedCallback() {
    this.#tomSelect?.destroy()
    this.#tomSelect = null
  }

  focus() {
    focusTomSelect(this.#tomSelect, () => super.focus())
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
      // Behave like the local <alchemy-select>: focusing neither opens the
      // dropdown nor fires a search. The first page of results is loaded when
      // the dropdown opens (see onDropdownOpen), i.e. on click or typing.
      openOnFocus: false,
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
      const added = this.#itemData(tomSelect.options[value])
      this.#selectedItem = added
      this.onChange({ added, removed: previous })
    }
  }

  /**
   * An option also carries the bookkeeping Tom Select keeps on it, among it the
   * node it was rendered into. Serializing that into the selection attribute
   * breaks the render cache once a component is attached to it again, so keep
   * the record itself only.
   * @param {?object} option
   * @returns {?object}
   * @private
   */
  #itemData(option) {
    if (!option) return null
    return Object.fromEntries(
      Object.entries(option).filter(([key]) => !key.startsWith("$"))
    )
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
   * Renders a dropdown option from the slots a subclass describes in `_entry`.
   * External subclasses that still override `_renderListEntry` directly keep
   * their own markup and never reach this.
   * @param {object} item
   * @param {string} term
   * @returns {string}
   * @private
   */
  _renderListEntry(item, term) {
    return this.#renderEntry(this._entry(item, term))
  }

  /**
   * Renders the selected item (shown in the control) from the slots a subclass
   * describes in `_selectedEntry`. External subclasses that still override
   * `_renderResult` directly keep their own markup and never reach this.
   * @param {object} item
   * @returns {string}
   * @private
   */
  _renderResult(item) {
    return this.#renderSelection(this._selectedEntry(item))
  }

  /**
   * Describes the slots of a dropdown option. Subclasses override this and
   * return an object with any of `icon`/`media`, `primary`, `aside`,
   * `secondary`, and `secondaryAside`. See `#renderEntry` for the accepted
   * value shapes.
   * @param {object} item
   * @param {string} term
   * @returns {object}
   * @protected
   */
  _entry() {
    throw new Error("You need to define an _entry function on your sub class!")
  }

  /**
   * Describes the slots of the selected item shown in the control. Subclasses
   * override this and return an object with `icon`/`media`, `primary`, and
   * `secondary`.
   * @param {object} item
   * @returns {object}
   * @protected
   */
  _selectedEntry() {
    throw new Error(
      "You need to define a _selectedEntry function on your sub class!"
    )
  }

  /**
   * Builds the two row grid markup of a dropdown option from its slots.
   * @param {object} slots
   * @returns {string}
   * @private
   */
  #renderEntry(slots) {
    return `
      <div class="remote-select--entry">
        ${this.#leadColumn(slots)}
        ${this.#cell("remote-select--primary", slots.primary, { raw: true })}
        ${this.#cell("remote-select--aside", slots.aside)}
        ${this.#cell("remote-select--secondary", slots.secondary)}
        ${this.#cell("remote-select--secondary-aside", slots.secondaryAside)}
      </div>
    `
  }

  /**
   * Builds the single row markup of the selected item from its slots. Only the
   * leading column, the primary text, and the (fast shrinking) secondary text
   * are shown; the compact control has no room for more.
   * @param {object} slots
   * @returns {string}
   * @private
   */
  #renderSelection(slots) {
    return `
      <div class="remote-select--selection">
        ${this.#leadColumn(slots)}
        ${this.#cell("remote-select--selection-name", slots.primary, { raw: true })}
        ${this.#cell("remote-select--selection-aside", slots.secondary)}
      </div>
    `
  }

  /**
   * Builds the leading column, either an icon or a media thumbnail. The two are
   * mutually exclusive; the icon wins if a subclass passes both.
   * @param {object} slots
   * @returns {string}
   * @private
   */
  #leadColumn(slots) {
    if (slots.icon) {
      return `<alchemy-icon class="remote-select--icon" name="${escapeHtml(slots.icon)}"></alchemy-icon>`
    }
    if (slots.media) {
      return `<img class="remote-select--media" src="${escapeHtml(slots.media)}" alt="">`
    }
    return ""
  }

  /**
   * Renders a single cell from a slot value. Omitted or empty values render
   * nothing. A string is escaped, unless `raw` is set (the primary text is
   * pre-highlighted HTML). `{ text, truncate: "head" }` wraps the text in
   * `<bdi>` and truncates it from the head. `{ badge }` renders the pill style.
   * @param {string} className
   * @param {(string|object)} value
   * @param {{raw?: boolean}} [options]
   * @returns {string}
   * @private
   */
  #cell(className, value, { raw = false } = {}) {
    if (value == null || value === "") return ""

    if (typeof value === "object") {
      if (value.badge != null && value.badge !== "") {
        return `<span class="${className} remote-select--badge">${escapeHtml(value.badge)}</span>`
      }
      if (value.text == null || value.text === "") return ""
      const text = raw ? value.text : escapeHtml(value.text)
      if (value.truncate === "head") {
        return `<span class="${className} remote-select--truncate-head"><bdi>${text}</bdi></span>`
      }
      return `<span class="${className}">${text}</span>`
    }

    return `<span class="${className}">${raw ? value : escapeHtml(value)}</span>`
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
