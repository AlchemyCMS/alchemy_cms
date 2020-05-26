$.fn.alchemyNodeSelect = function (options) {
  var renderNodeTemplate = function (node) {
    return HandlebarsTemplates.node({ node: node })
  }
  var queryParamsFromTerm = function (term) {
    return {
      filter: Object.assign(
        { name_or_page_name_cont: term },
        options.query_params
      )
    }
  }
  var resultsFromResponse = function (response) {
    var meta = response.meta
    var data = response.data
    var more = meta.page * meta.per_page < meta.total_count
    return { results: data, more: more }
  }

  return this.select2({
    placeholder: options.placeholder,
    allowClear: true,
    minimumInputLength: 3,
    initSelection: function (_$el, callback) {
      if (options.initialSelection) {
        callback(options.initialSelection)
      }
    },
    ajax: {
      url: options.url,
      datatype: "json",
      quietMillis: 300,
      data: queryParamsFromTerm,
      results: resultsFromResponse
    },
    formatSelection: renderNodeTemplate,
    formatResult: renderNodeTemplate
  })
}
