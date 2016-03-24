tinymce.PluginManager.add('alchemy_link', function(editor, url) {
  editor.addButton('alchemy_link', {
    icon: 'link',
    tooltip: 'Insert/edit link',
    shortcut: 'Ctrl+K',
    stateSelector: 'a[href]',
    onclick: function () {
      var linkObject = {
        node: editor.selection.getNode(),
        bookmark: editor.selection.getBookmark(),
        selection: editor.selection,
        editor: editor
      };
      var linkDialog = new Alchemy.LinkDialog(linkObject);
      editor.focus();
      linkDialog.open();
    }
  });
});
