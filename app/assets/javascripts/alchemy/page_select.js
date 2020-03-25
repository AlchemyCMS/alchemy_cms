$.fn.alchemyPageSelect = function(options) {
  var pageTemplate = HandlebarsTemplates.page

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
      data: function (term, page) {
        return {
          q: $.extend({
            name_cont: term
          }, options.query_params),
          page: page
        }
      },
      results: function (data) {
        var meta = data.meta

        return {
          results: data.pages,
          more: meta.page * meta.per_page < meta.total_count
        }
      }
    },
    formatSelection: function (page) {
      return page.text || page.name
    },
    formatResult: function(page) {
      return pageTemplate({page: page})
    }
  })
}
