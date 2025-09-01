import { hightlightTerm } from "alchemy_admin/components/remote_select"

const formatItem = (icon, text) => {
  return `<div class="element-select-item">${icon} ${text}</div>`
}

class ElementSelect extends HTMLInputElement {
  constructor() {
    super()
    this.classList.add("alchemy_selectbox")
  }

  connectedCallback() {
    const el = this
    const options = {
      minimumResultsForSearch: 3,
      dropdownAutoWidth: true,
      data() {
        return { results: JSON.parse(el.dataset.options) }
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
      }
    }
    $(this).select2(options)
  }
}

customElements.define("alchemy-element-select", ElementSelect, {
  extends: "input"
})
