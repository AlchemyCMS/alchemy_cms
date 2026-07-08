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

// Dropdown positioning shared by the Tom Select based components. It appends the
// dropdown to the body and keeps it positioned with Floating UI so it is not
// clipped inside dialogs or scrollable panels. The returned handlers are used as
// Tom Select `onDropdownOpen`/`onDropdownClose` callbacks and are therefore
// invoked with the Tom Select instance as `this`.
export function createDropdownPositioning() {
  const dropdownMask = document.createElement("div")
  dropdownMask.className = "ts-dropdown-mask"

  let removeAutoUpdater = () => {}

  return {
    async onDropdownOpen() {
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
                  elements.floating.querySelector(".ts-dropdown-content").style,
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
    onDropdownClose() {
      // Remove the dropdown from DOM when closed.
      this.dropdown.remove()
      dropdownMask.remove()
      // Cleanup the position auto-update when the dropdown is closed.
      removeAutoUpdater()
    }
  }
}

// Customize the "create" and "no results" dropdown messages with i18n. Shared by
// the Tom Select based components as `render` functions.
export const dropdownMessages = {
  option_create(data, escape) {
    return `<div class="create">
      ${translate("Add")} <strong>${escape(data.input)}</strong>&hellip;
    </div>`
  },
  no_results() {
    return `<div class="no-results">${translate("No results found")}</div>`
  },
  // Shown at the bottom of the dropdown while the virtual scroll plugin appends
  // the next page of results.
  loading_more: () =>
    `<div class="loading-more">${translate("Loading more results")}&hellip;</div>`,
  // Shown at the bottom of the dropdown once every page has been loaded.
  no_more_results: () =>
    `<div class="no-more-results">${translate("No more results")}</div>`
}
