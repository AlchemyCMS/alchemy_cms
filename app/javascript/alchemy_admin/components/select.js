import TomSelect from "tom-select"
import { translate } from "alchemy_admin/i18n"
import {
  autoUpdate,
  computePosition,
  flip,
  offset,
  size
} from "@floating-ui/dom"

const DROPDOWN_WINDOW_MARGIN = 16
const DROPDOWN_MIN_HEIGHT = 120

export class Select extends HTMLSelectElement {
  #tomSelect = null

  connectedCallback() {
    this.classList.add("alchemy_selectbox")
    this.#initTomSelect()
  }

  disconnectedCallback() {
    this.#destroyTomSelect()
  }

  enable() {
    this.removeAttribute("disabled")
    this.#tomSelect?.enable()
  }

  disable() {
    this.setAttribute("disabled", "disabled")
    this.#tomSelect?.disable()
  }

  setOptions(data, prompt = undefined) {
    const selectedValue = this.value

    // Tom Select needs to be rebuilt from the new native options, so tear it
    // down, replace the options and initialize it again.
    this.#destroyTomSelect()

    // reset the old options and insert the placeholder(s) first
    this.innerHTML = ""
    if (prompt) {
      this.add(new Option(prompt, ""))
    }

    // add the new options to the select
    data.forEach((item) => {
      this.add(new Option(item.text, item.id, false, item.id === selectedValue))
    })

    this.#initTomSelect()
  }

  get allowClear() {
    return this.dataset.hasOwnProperty("allowClear") || this.multiple
  }

  get placeholder() {
    return this.getAttribute("placeholder")
  }

  // Subclasses may return extra Tom Select render functions (e.g. custom
  // `option`/`item` templates) to merge on top of the defaults below.
  get renderers() {
    return {}
  }

  #initTomSelect() {
    const plugins = {}
    const hasPlaceholder = !!this.placeholder
    // Capture this before Tom Select initializes, since it rewrites the
    // select's selected option during setup.
    const hasSelectedOption = !!this.querySelector("option[selected]")
    const dropdownMask = document.createElement("div")
    dropdownMask.className = "ts-dropdown-mask"

    let removeAutoUpdater = () => {}

    if (this.multiple) {
      plugins.remove_button = {
        title: translate("Remove")
      }
    }

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

    const settings = {
      plugins,
      closeAfterSelect: !this.multiple,
      onInitialize: function () {
        if (this.input.autofocus) {
          this.focus()
        }
        // Tom Select auto-selects the first option when none is selected. With
        // a placeholder we want it to start empty instead, but only clear when
        // no option was explicitly marked selected, so a preselected value is
        // preserved.
        if (hasPlaceholder && !hasSelectedOption) {
          this.clear()
        }
      },
      onType(term) {
        this.control_input.classList.toggle("has-value", term.length > 0)
      },
      // remove the transition after selection of option.
      refreshThrottle: 0,
      onDropdownOpen: async function () {
        // Make the dropdown at least as wide as the control.
        const styles = {
          minWidth: `${this.control.offsetWidth}px`
        }
        // If the select is inside a dialog, we need to ensure the dropdown appears above it.
        if (this.control.closest(".alchemy-dialog-body, .alchemy-popover")) {
          styles.zIndex = "101"
        }
        Object.assign(this.dropdown.style, styles)
        // Append the dropdown to the body to avoid overflow issues, especially in dialogs.
        document.body.append(dropdownMask)
        document.body.append(this.dropdown)
        // Use Floating UI to position the dropdown relative to the control.
        const updatePosition = async () => {
          // Use Floating UI to calculate the dropdown position
          const { x, y } = await computePosition(this.control, this.dropdown, {
            middleware: [
              // Flip to the opposite side if there’s not enough space
              flip(),
              // Make some space between the control and the dropdown to prevent overlap
              offset(2),
              // Ensure the dropdown fits within the viewport
              size({
                apply({ availableHeight, elements }) {
                  Object.assign(
                    elements.floating.querySelector(".ts-dropdown-content")
                      .style,
                    {
                      maxHeight: `${Math.max(DROPDOWN_MIN_HEIGHT, availableHeight - DROPDOWN_WINDOW_MARGIN)}px`
                    }
                  )
                }
              })
            ]
          })
          // Position the dropdown
          Object.assign(this.dropdown.style, {
            left: `${x}px`,
            top: `${y}px`
          })
        }
        // Update the dropdown position whenever the window resizes or scrolls.
        removeAutoUpdater = autoUpdate(
          this.control,
          this.dropdown,
          updatePosition
        )
      },
      onDropdownClose: function () {
        this.control_input.classList.remove("has-value")
        // Remove the dropdown from DOM when closed.
        this.dropdown.remove()
        dropdownMask.remove()
        // Cleanup the position auto-update when the dropdown is closed.
        removeAutoUpdater()
      },
      allowEmptyOption: true,
      openOnFocus: false,
      // Keep options in their original order instead of sorting by value.
      sortField: "$order",
      // Show every option, not just the first 50 (e.g. the timezone select).
      maxOptions: null,
      // Customize the "create" and "no results" dropdown messages with i18n.
      render: {
        option_create(data, escape) {
          return `<div class="create">
            ${translate("Add")}<strong>${escape(data.input)}</strong>&hellip;
          </div>`
        },
        no_results() {
          return `<div class="no-results">${translate("No results found")}</div>`
        },
        ...this.renderers
      }
    }

    this.#tomSelect = new TomSelect(this, settings)

    // Mimick the native select's click-to-open behavior.
    this.#tomSelect.control.addEventListener(
      "click",
      this.#tomSelect.open.bind(this.#tomSelect)
    )
  }

  #destroyTomSelect() {
    this.#tomSelect?.destroy()
    this.#tomSelect = null
  }
}

customElements.define("alchemy-select", Select, { extends: "select" })
