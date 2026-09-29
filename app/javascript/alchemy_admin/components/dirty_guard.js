import { Turbo } from "@hotwired/turbo-rails"
import { openConfirmDialog } from "alchemy_admin/confirm_dialog"
import { translate } from "alchemy_admin/i18n"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

// Set once the user agreed to leave, so that the navigation they agreed to is
// not questioned again: a guarded form's redirect comes back through
// turbo:before-visit.
let leaveConfirmed = false

// Warns before a wrapped form takes the user away from a page that has unsaved
// element changes. Links need no wrapping, turbo:before-visit covers them, but
// Turbo dispatches that for a form only once its request has returned, which is
// too late for a form that changes something on the server.
//
// Guards in the capture phase, so that a cancelled submit never reaches
// Turbo's document level handlers, nor any component the guard sits in.
//
// Wrap an sl-tooltip, never the element inside it: Shoelace anchors to its
// first slotted child, and this element has no box of its own to anchor to.
class DirtyGuard extends HTMLElement {
  connectedCallback() {
    this.addEventListener("submit", this.#guard, true)
  }

  disconnectedCallback() {
    this.removeEventListener("submit", this.#guard, true)
  }

  #guard = (event) => {
    if (leaveConfirmed || !isPageDirty()) return

    event.preventDefault()
    event.stopPropagation()

    const form = event.target
    confirmLeave().then((confirmed) => {
      if (confirmed) {
        pleaseWaitOverlay()
        form.requestSubmit()
      }
    })
  }
}

function isPageDirty() {
  return document.querySelectorAll("alchemy-element-editor.dirty").length > 0
}

async function confirmLeave() {
  const confirmed = await openConfirmDialog(translate("page_dirty_notice"), {
    title: translate("warning"),
    ok_label: translate("ok"),
    cancel_label: translate("cancel")
  })
  if (confirmed) {
    leaveConfirmed = true
    window.onbeforeunload = void 0
  }
  return confirmed
}

document.addEventListener("turbo:before-visit", (event) => {
  if (leaveConfirmed || !isPageDirty()) return

  event.preventDefault()

  confirmLeave().then((confirmed) => {
    if (confirmed) Turbo.visit(event.detail.url)
  })
})

document.addEventListener("turbo:load", () => {
  leaveConfirmed = false
})

customElements.define("alchemy-dirty-guard", DirtyGuard)
