import "clipboard"

const clipboard = new ClipboardJS("[data-clipboard-text]")

clipboard.on("success", (e) => {
  Alchemy.growl(e.trigger.dataset.clipboardSuccessText)
  e.clearSelection()
})

const currentDialog = Alchemy.currentDialog()

if (currentDialog) {
  currentDialog.dialog.on("DialogClose.Alchemy", () => {
    clipboard.destroy()
  })
}
