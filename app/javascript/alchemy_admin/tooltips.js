import { createHtmlElement, wrap } from "alchemy_admin/dom_helpers"

/**
 * show tooltips on fixed inputs
 * @param {Element|Document} baseElement
 * @constructor
 */
export default function Tooltips(baseElement) {
  baseElement.querySelectorAll("[data-alchemy-tooltip]").forEach((element) => {
    const text = element.dataset.alchemyTooltip

    wrap(element, createHtmlElement('<div class="with-hint" />'))
    element.after(createHtmlElement(`<span class="hint-bubble">${text}</span>`))
  })
}
