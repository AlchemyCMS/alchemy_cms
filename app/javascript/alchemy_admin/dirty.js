import { openConfirmDialog } from "alchemy_admin/confirm_dialog"
import { translate } from "alchemy_admin/i18n"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"

function checkPageDirtyness(element) {
  let callback = () => {}

  if ($(element).is("form")) {
    callback = function () {
      const $form = $(
        `<form action="${element.action}" method="POST" style="display: none" />`
      )
      $form.append($(element).find("input"))
      $form.appendTo("body")

      pleaseWaitOverlay()
      $form.trigger("submit")
    }
  } else if ($(element).is("a")) {
    callback = () => Turbo.visit(element.pathname)
  }

  const isPageDirty =
    document.querySelectorAll("alchemy-element-editor.dirty").length > 0

  if (isPageDirty) {
    openConfirmDialog(translate("page_dirty_notice"), {
      title: translate("warning"),
      ok_label: translate("ok"),
      cancel_label: translate("cancel")
    }).then((proceed) => {
      if (proceed) {
        window.onbeforeunload = void 0
        callback()
      }
    })
    return false
  }
  return true
}

function PageLeaveObserver() {
  document.querySelectorAll("#main_navi a").forEach((element) => {
    element.addEventListener("click", (event) => {
      if (!checkPageDirtyness(event.currentTarget)) {
        event.preventDefault()
      }
    })
  })
}

export default {
  checkPageDirtyness,
  PageLeaveObserver
}
