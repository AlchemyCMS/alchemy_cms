import { openConfirmDialog } from "alchemy_admin/confirm_dialog"
import { translate } from "alchemy_admin/i18n"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

// Warns before a wrapped form or link takes the user away from a page that has
// unsaved element changes.
//
// Guards in the capture phase, so that a cancelled navigation never reaches
// Turbo's document level handlers, nor any component the guard sits in.
//
// Wrap an sl-tooltip, never the element inside it: Shoelace anchors to its
// first slotted child, and this element has no box of its own to anchor to.
class DirtyGuard extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this.#guard, true)
    this.addEventListener("click", this.#guard, true)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this.#guard, true)
    this.removeEventListener("click", this.#guard, true)
  }

  #guard = (event) => {
    const target =
      event.type === "submit" ? event.target : event.target.closest("a")
    if (!target) return

    if (!checkPageDirtyness(target)) {
      event.preventDefault()
      event.stopPropagation()
    }
  }
}

function checkPageDirtyness(element) {
  let callback = () => {}

  if (element.matches("form")) {
    callback = function () {
      const form = document.createElement("form")
      form.action = element.action
      form.method = "POST"
      form.style.display = "none"
      element.querySelectorAll("input").forEach((input) => form.append(input))
      document.body.append(form)

      pleaseWaitOverlay()
      form.requestSubmit()
    }
  } else if (element.matches("a")) {
    callback = () => Turbo.visit(element.pathname)
  }

  const isPageDirty =
    document.querySelectorAll("alchemy-element-editor.dirty").length > 0

  if (isPageDirty) {
    openConfirmDialog(translate("page_dirty_notice"), {
      title: translate("warning"),
      ok_label: translate("ok"),
      cancel_label: translate("cancel")
    }).then((proceed) => {
      if (proceed) {
        window.onbeforeunload = void 0
        callback()
      }
    })
    return false
  }
  return true
}

customElements.define("alchemy-dirty-guard", DirtyGuard)
