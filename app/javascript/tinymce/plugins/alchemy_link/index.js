tinymce.PluginManager.add("alchemy_link", function (editor) {
  const getAnchor = (selectedElm) => {
    return editor.dom.getParent(selectedElm, "a[href]")
  }

  const openLinkDialog = () => {
    if (Alchemy.currentDialog()) return

    let link = {}
    const anchor = getAnchor(editor.selection.getNode())
    if (anchor) {
      link = {
        url: anchor.getAttribute("href"), // avoid getting an absolute URL
        title: anchor.title,
        target: anchor.target,
        type: anchor.className
      }
    }
    const linkDialog = new Alchemy.LinkDialog(link)
    editor.focus()
    linkDialog.open().then((link) => {
      editor.execCommand("mceInsertLink", false, {
        href: link.url,
        class: link.type,
        title: link.title,
        target: link.target
      })
      editor.selection.collapse()
    })
  }

  editor.ui.registry.addToggleButton("alchemy_link", {
    icon: "link",
    tooltip: "Insert/edit link",
    onSetup(buttonApi) {
      const onNodeChange = () => {
        buttonApi.setActive(getAnchor(editor.selection.getNode()) !== null)
      }
      onNodeChange()
      editor.on("NodeChange", onNodeChange)
      return () => {
        editor.off("NodeChange", onNodeChange)
      }
    },
    onAction: openLinkDialog
  })

  // Replace the default link command with our own
  editor.addCommand("mceLink", openLinkDialog)
  editor.addShortcut("Meta+K", "", openLinkDialog)
})
