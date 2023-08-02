function ElementDirtyObserver(selector) {
  $(selector)
    .find('input[type="text"], select')
    .change(function (event) {
      const $content = $(event.target)
      $content.addClass("dirty")
      setElementDirty($content.closest(".element-editor"))
    })
}

function setElementDirty(element) {
  $(element).addClass("dirty")
  window.onbeforeunload = () => Alchemy.t("page_dirty_notice")
}

function setElementClean(element) {
  const $element = $(element)
  $element.removeClass("dirty")
  $element.find("> .element-body .dirty").removeClass("dirty")
  window.onbeforeunload = () => {}
}

function isPageDirty() {
  return $("#element_area").find(".element-editor.dirty").length > 0
}

function isElementDirty(element) {
  return $(element).hasClass("dirty")
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
  $("#main_navi a").click(function (event) {
    if (!checkPageDirtyness(event.currentTarget)) {
      event.preventDefault()
    }
  })
}

export default {
  ElementDirtyObserver,
  setElementDirty,
  setElementClean,
  isElementDirty,
  checkPageDirtyness,
  PageLeaveObserver
}
