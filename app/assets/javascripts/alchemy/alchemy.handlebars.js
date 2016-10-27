if (window.Alchemy == undefined) {
  window.Alchemy = {};
}

Alchemy.Handlebars = function() {
  $('[data-handlebars-partial]').each(function() {
    var $this = $(this),
        name = $this.data('handlebars-partial'),
        compiled = Handlebars.compile($this.html());

    Handlebars.registerPartial(name, compiled);
  });

  Handlebars.registerHelper('json', function(context) {
    return JSON.stringify(context);
  });
}
