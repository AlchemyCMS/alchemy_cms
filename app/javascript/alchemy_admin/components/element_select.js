import { hightlightTerm } from "alchemy_admin/components/remote_select"

const formatSelection = (option) => {
  return `
    <div class="element-select-name">${option.icon} ${option.name}</div>
  `
}

const formatItem = (icon, name, hint) => {
  const description = hint
    ? `<div class="element-select-description">${hint}</div>`
    : ""
  return `
    <div class="element-select-item">
      ${formatSelection({ icon, name })}
      ${description}
    </div>
  `
}

class ElementSelect extends HTMLElement {
  constructor() {
    super()
  }

  connectedCallback() {
    const results = this.options
    const options = {
      minimumResultsForSearch: 3,
      dropdownAutoWidth: true,
      data() {
        return { results }
      },
      formatResult: (option, _el, search) => {
        let text

        if (option.id === "") return option.name
        if (search.term !== "") {
          text = hightlightTerm(option.name, search.term)
        } else {
          text = option.name
        }

        return formatItem(option.icon, text, option.hint)
      },
      formatSelection,
      placeholder: this.placeholder
    }
    $(this.inputField).select2(options)
  }

  get options() {
    return JSON.parse(this.getAttribute("options"))
  }

  get placeholder() {
    return this.getAttribute("placeholder")
  }

  get inputField() {
    return this.querySelector("input")
  }
}

customElements.define("alchemy-element-select", ElementSelect)
