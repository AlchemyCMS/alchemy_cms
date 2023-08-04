/**
 * Multiple picture select handler for the picture archive.
 */
export default function PictureSelector() {
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
