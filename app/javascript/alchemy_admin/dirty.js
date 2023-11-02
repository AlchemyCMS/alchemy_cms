function isPageDirty() {
  return $("#element_area").find("alchemy-element-editor.dirty").length > 0
}

function checkPageDirtyness(element) {
  let callback = () => {}

  if ($(element).is("form")) {
    callback = function () {
      const $form = $(
        `<form action="${element.action}" method="POST" style="display: none" />`
      )
      $form.append($(element).find("input"))
      $form.appendTo("body")

      Alchemy.pleaseWaitOverlay()
      $form.submit()
    }
  } else if ($(element).is("a")) {
    callback = () => Turbo.visit(element.pathname)
  }

  if (isPageDirty()) {
    Alchemy.openConfirmDialog(Alchemy.t("page_dirty_notice"), {
      title: Alchemy.t("warning"),
      ok_label: Alchemy.t("ok"),
      cancel_label: Alchemy.t("cancel"),
      on_ok: function () {
        window.onbeforeunload = void 0
        callback()
      }
    })
    return false
  }
  return true
}

function PageLeaveObserver() {
  $("#main_navi a").on("click", function (event) {
    if (!checkPageDirtyness(event.currentTarget)) {
      event.preventDefault()
    }
  })
}

export default {
  checkPageDirtyness,
  PageLeaveObserver
}
