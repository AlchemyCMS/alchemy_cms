if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

Alchemy.loadAlchemyMenuBar = function(options) {

  Alchemy.Menubar = {

    init: function ($) {
      var self = Alchemy.Menubar;
      self._$ = $;
      self.show();
    },

    show: function() {
      var self = Alchemy.Menubar;
      self._$('body').prepend(Alchemy.Menubar.build());
    },

    build: function() {
      var self = Alchemy.Menubar;
      var bar = self._$('<div id="alchemy_menubar"/>').append('<ul/>');
      bar.find('ul').append('<li><a href="' + options.route + '/admin">' + Alchemy.Menubar.t("to_alchemy") + '</a></li>').append('<li><a href="' + options.route + '/admin/pages/' + options.page_id + '/edit">' + Alchemy.Menubar.t("edit_page") + '</a></li>').append('<li><a href="' + options.route + '/admin/logout">' + Alchemy.Menubar.t("logout") + '</a></li>');
      return bar;
    },

    translations: {
      'to_alchemy': {
        'de': 'zu Alchemy',
        'en': 'To Alchemy'
      },
      'edit_page': {
        'de': 'Seite bearbeiten',
        'en': 'Edit Page'
      },
      'logout': {
        'de': 'abmelden',
        'en': 'Log out'
      }
    },

    t: function(id) {
      var translation = Alchemy.Menubar.translations[id];
      if (translation) {
        return translation[options.locale];
      } else {
        return id;
      }
    }

  };

  if (typeof(jQuery) === 'undefined') {
    Alchemy.loadjQuery(Alchemy.Menubar.init);
  } else {
    Alchemy.Menubar.init(jQuery);
  }

};
