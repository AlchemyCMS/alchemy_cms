tinymce.PluginManager.add('alchemy_link', function(editor, url) {
  editor.addButton('alchemy_link', {
    icon: 'link',
    tooltip: 'Insert/edit link',
    shortcut: 'Ctrl+K',
    stateSelector: 'a[href]',
    onclick: function () {
      var link_object = {
        node: editor.selection.getNode(),
        bookmark: editor.selection.getBookmark(),
        selection: editor.selection,
        editor: editor
      };
      var link_dialog = new Alchemy.LinkDialog(link_object);
      editor.focus();
      link_dialog.open();
    }
  });
});
