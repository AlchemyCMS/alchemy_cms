(function () {
  tinymce.PluginManager.requireLangPack('alchemy_link');

  tinymce.create('tinymce.plugins.alchemy_link', {
    init:function (ed, url) {
      ed.addButton('alchemy_link', {
        title:'alchemy_link.link_button_title',
        label:'',
        'class':'alchemy_link',
        onclick:function () {
          ed.focus();
          Alchemy.LinkOverlay.open({
            node:ed.selection.getNode(),
            bookmark:ed.selection.getBookmark(),
            selection:ed.selection,
            editor:ed
          });
        }
      });
      ed.onNodeChange.add(function (ed, cm, n, co) {
        // Activates the link button when the caret is placed in a anchor element
        cm.setActive('alchemy_link', n.nodeName == 'A');
      });
    },

    createControl:function (n, cm) {
      return null;
    },

    getInfo:function () {
      return {
        longname:'Link overlay plugin for Alchemy',
        author:'magic labs*',
        authorurl:'http://magiclabs.de',
        infourl:'http://alchemy-app.com',
        version:"0.4.0"
      };
    }
  });

  tinymce.PluginManager.add('alchemy_link', tinymce.plugins.alchemy_link);
})();
