/**
 * Initializes all select tag with .alchemy_selectbox class as select2 instance
 * Pass a jQuery scope to only init a subset of selectboxes.
 * @param scope
 */
export default function SelectBox(scope) {
  $("select.alchemy_selectbox", scope).select2({
    minimumResultsForSearch: 7,
    dropdownAutoWidth: true
  })
}
