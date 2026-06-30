import { Select } from "alchemy_admin/components/select"

const renderName = (icon, text) => `
  <div class="element-select-name">
    ${icon}<span>${text}</span>
  </div>
`

export class ElementSelect extends Select {
  get renderers() {
    return {
      item: (data, escape) => renderName(data.icon, escape(data.text)),
      option: (data, escape) => {
        const description = data.hint
          ? `<div class="element-select-description">${escape(data.hint)}</div>`
          : ""
        return `
          <div class="element-select-item">
            ${renderName(data.icon, escape(data.text))}
            ${description}
          </div>
        `
      }
    }
  }
}

customElements.define("alchemy-element-select", ElementSelect, {
  extends: "select"
})
