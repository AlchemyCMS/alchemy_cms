function initSelection(element, callback) {
  let data = []
  $(element.val().split(",")).each(function () {
    return data.push({
      id: $.trim(this),
      text: this
    })
  })
  return callback(data)
}

function createSearchChoice(term, data) {
  const hasResult =
    $(data).filter(function () {
      return this.text.localeCompare(term) === 0
    }).length === 0

  if (hasResult) {
    return {
      id: term,
      text: term
    }
  }
}

export default function Autocomplete(scope) {
  const field = $("[data-autocomplete]", scope)
  const url = field.data("autocomplete")

  return field.select2({
    tags: true,
    tokenSeparators: [","],
    minimumInputLength: 1,
    openOnEnter: false,
    createSearchChoice,
    initSelection,
    ajax: {
      url: url,
      dataType: "json",
      data: function (term, page) {
        return {
          term: term
        }
      },
      results: function (data, page) {
        return {
          results: data
        }
      }
    }
  })
}
