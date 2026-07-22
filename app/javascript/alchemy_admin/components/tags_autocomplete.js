import TomSelect from "tom-select"
import { get } from "alchemy_admin/utils/ajax"
import { growl } from "alchemy_admin/growler"
import {
  createDropdownPositioning,
  dropdownMessages,
  focusTomSelect,
  removeButton
} from "alchemy_admin/utils/tom_select"

export class TagsAutocomplete extends HTMLElement {
  #tomSelect = null

  connectedCallback() {
    this.classList.add("autocomplete_tag_list")
    // Reuse the shared Tom Select styling by tagging the source input, whose
    // class Tom Select copies onto the generated wrapper.
    this.input.classList.add("alchemy_selectbox")
    this.#tomSelect = new TomSelect(this.input, this.settings)
  }

  disconnectedCallback() {
    this.#tomSelect?.destroy()
    this.#tomSelect = null
  }

  focus() {
    focusTomSelect(this.#tomSelect, () => super.focus())
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }

  get settings() {
    return {
      plugins: {
        remove_button: removeButton()
      },
      // The autocomplete endpoint returns each tag as `{ id, text }`.
      valueField: "id",
      // Tags are entered and stored as a comma separated list.
      delimiter: ",",
      // Allow free tagging.
      create: true,
      // Hide the "Add …" create option while suggestions are still loading, so
      // it doesn't flash and then disappear once a matching tag arrives from
      // the server. When idle, keep Tom Select's default of not offering to
      // create a tag that already exists.
      createFilter(input) {
        if (this.loading) return false
        return this.settings.duplicates || !this.options[input]
      },
      // Do not keep a removed tag around as a lingering suggestion.
      persist: false,
      // Clear the typed text once a tag is added, so it doesn't linger in the
      // input after selecting an existing tag.
      clearAfterSelect: true,
      // Show every matching tag returned by the server.
      maxOptions: null,
      openOnFocus: false,
      // Apply the placeholder set on the wrapper element.
      placeholder: this.getAttribute("placeholder"),
      // Load matching tags from the server as the user types.
      load: (query, callback) => {
        get(this.getAttribute("url"), { term: query })
          .then((response) => callback(response.data))
          .catch((error) => {
            growl(error.message || error, "error")
            // Tom Select stays in loading state until the callback runs.
            callback()
          })
      },
      ...createDropdownPositioning(),
      render: {
        ...dropdownMessages
      }
    }
  }
}

customElements.define("alchemy-tags-autocomplete", TagsAutocomplete)
