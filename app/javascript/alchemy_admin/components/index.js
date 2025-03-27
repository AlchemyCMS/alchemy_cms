import "alchemy_admin/components/action"
import "alchemy_admin/components/attachment_select"
import "alchemy_admin/components/button"
import "alchemy_admin/components/char_counter"
import "alchemy_admin/components/clipboard_button"
import "alchemy_admin/components/datepicker"
import "alchemy_admin/components/dialog_link"
import "alchemy_admin/components/dom_id_select"
import "alchemy_admin/components/element_editor"
import "alchemy_admin/components/elements_window"
import "alchemy_admin/components/elements_window_handle"
import "alchemy_admin/components/list_filter"
import "alchemy_admin/components/message"
import "alchemy_admin/components/growl"
import "alchemy_admin/components/icon"
import "alchemy_admin/components/ingredient_group"
import "alchemy_admin/components/link_buttons"
import "alchemy_admin/components/node_select"
import "alchemy_admin/components/uploader"
import "alchemy_admin/components/overlay"
import "alchemy_admin/components/page_select"
import "alchemy_admin/components/preview_window"
import "alchemy_admin/components/select"
import "alchemy_admin/components/spinner"
import "alchemy_admin/components/tags_autocomplete"
import "alchemy_admin/components/tinymce"

await Promise.race([
  // Load all global custom elements
  Promise.allSettled([
    customElements.whenDefined("alchemy-button"),
    customElements.whenDefined("alchemy-icon"),
    customElements.whenDefined("alchemy-growl"),
    customElements.whenDefined("alchemy-message"),
    customElements.whenDefined("alchemy-spinner")
  ]),
  // Resolve after two seconds
  new Promise((resolve) => setTimeout(resolve, 1250))
])

// Remove the class, showing the page content
document.documentElement.classList.remove("loading-custom-elements")
