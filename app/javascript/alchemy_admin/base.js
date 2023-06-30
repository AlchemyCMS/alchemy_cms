/**
 * The Alchemy object contains all base functions, that don't fit in its own module.
 * All other modules uses this global Alchemy object as namespace.
 */

/**
 * Multiple picture select handler for the picture archive.
 */
function pictureSelector() {
  const $selected_item_tools = $(".selected_item_tools")
  const $picture_selects = $(".picture_tool.select input")

  $picture_selects.on("change", function () {
    if ($picture_selects.filter(":checked").size() > 0) {
      $selected_item_tools.show()
    } else {
      $selected_item_tools.hide()
    }

    if (this.checked) {
      $(this).parent().addClass("visible").removeClass("hidden")
    } else {
      $(this).parent().removeClass("visible").addClass("hidden")
    }
  })

  $("a#edit_multiple_pictures").on("click", function (e) {
    const $this = $(this)
    const picture_ids = $("input:checkbox", "#picture_archive").serialize()
    const url = $this.attr("href") + "?" + picture_ids

    Alchemy.openDialog(url, {
      title: $this.attr("title"),
      size: "400x295"
    })
  })
}

/**
 * To show the "Please wait" overlay.
 * Pass false to hide it.
 * @param {boolean,null} show
 */
function pleaseWaitOverlay(show) {
  if (show == null) {
    show = true
  }
  const $overlay = $("#overlay")
  if (show) {
    const spinner = new Alchemy.Spinner("medium")
    spinner.spin($overlay)
    $overlay.show()
  } else {
    $overlay.find(".spinner").remove()
    $overlay.hide()
  }
}

/**
 * Initializes all select tag with .alchemy_selectbox class as select2 instance
 * Pass a jQuery scope to only init a subset of selectboxes.
 * @param scope
 */
function SelectBox(scope) {
  $("select.alchemy_selectbox", scope).select2({
    minimumResultsForSearch: 7,
    dropdownAutoWidth: true
  })
}

export default {
  pictureSelector,
  pleaseWaitOverlay,
  SelectBox
}
