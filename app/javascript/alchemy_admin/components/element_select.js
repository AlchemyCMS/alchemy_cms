import { hightlightTerm } from "alchemy_admin/components/remote_select"

const formatItem = (icon, text) => {
  return `<div class="element-select-item">${icon} ${text}</div>`
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

        if (option.id === "") return option.text
        if (search.term !== "") {
          text = hightlightTerm(option.text, search.term)
        } else {
          text = option.text
        }

        return formatItem(option.icon, text)
      },
      formatSelection: (option) => {
        return formatItem(option.icon, option.text)
      },
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
