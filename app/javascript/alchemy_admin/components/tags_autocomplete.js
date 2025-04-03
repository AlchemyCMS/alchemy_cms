import { setupSelectLocale } from "alchemy_admin/i18n"

class TagsAutocomplete extends HTMLElement {
  async connectedCallback() {
    await setupSelectLocale()

    this.classList.add("autocomplete_tag_list")
    $(this.input).select2(this.select2Config)
  }

  get input() {
    return this.getElementsByTagName("input")[0]
  }

  get select2Config() {
    return {
      tags: true,
      tokenSeparators: [","],
      openOnEnter: false,
      minimumInputLength: 1,
      createSearchChoice: this.#createSearchChoice,
      ajax: {
        url: this.getAttribute("url"),
        dataType: "json",
        data: (term) => {
          return { term }
        },
        results: (data) => {
          return { results: data }
        }
      },
      initSelection: this.#initSelection
    }
  }

  #createSearchChoice(term, data) {
    if (
      $(data).filter(function () {
        return this.text.localeCompare(term) === 0
      }).length === 0
    ) {
      return {
        id: term,
        text: term
      }
    }
  }

  #initSelection(element, callback) {
    const data = []
    $(element.val().split(",")).each(function () {
      data.push({
        id: this.trim(),
        text: this
      })
    })
    callback(data)
  }
}

customElements.define("alchemy-tags-autocomplete", TagsAutocomplete)
