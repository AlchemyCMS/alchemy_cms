$.fn.alchemyNodeSelect = function(options) {
  var renderNodeTemplate = (node) => HandlebarsTemplates.node({ node: node })
  var queryParamsFromTerm = (term) => {
    return {filter: Object.assign({ name_or_page_name_cont: term }, options.query_params)}
  }
  var resultsFromResponse = (response) => {
    var { meta, data } = response
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
      datatype: 'json',
      quietMillis: 300,
      data: queryParamsFromTerm,
      results: resultsFromResponse
    },
    formatSelection: renderNodeTemplate,
    formatResult: renderNodeTemplate
  })
}
