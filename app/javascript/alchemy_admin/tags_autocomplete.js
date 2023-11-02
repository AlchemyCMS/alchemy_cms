function createSearchChoice(term, data) {
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

function initSelection(element, callback) {
  const data = []
  $(element.val().split(",")).each(function () {
    data.push({
      id: this.trim(),
      text: this
    })
  })
  callback(data)
}

export default function TagsAutocomplete(scope) {
  const field = $("[data-autocomplete]", scope)
  const url = field.data("autocomplete")
  field.select2({
    tags: true,
    tokenSeparators: [","],
    minimumInputLength: 1,
    openOnEnter: false,
    createSearchChoice,
    ajax: {
      url,
      dataType: "json",
      data: (term) => {
        return { term }
      },
      results: (data) => {
        return { results: data }
      }
    },
    initSelection
  })
}
