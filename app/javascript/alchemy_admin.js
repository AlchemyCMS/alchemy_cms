// We still use jQuery in some places (ie. select2)
import "handlebars"
import "jquery"
import "@ungap/custom-elements"
import { Turbo } from "@hotwired/turbo-rails"
import "select2"

import Rails from "@rails/ujs"

import { translate } from "alchemy_admin/i18n"
import { currentDialog, closeCurrentDialog } from "alchemy_admin/dialog"
import Dirty from "alchemy_admin/dirty"
import * as FixedElements from "alchemy_admin/fixed_elements"
import { growl } from "alchemy_admin/growler"
import Initializer from "alchemy_admin/initializer"
import { LinkDialog } from "alchemy_admin/link_dialog"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import Spinner from "alchemy_admin/spinner"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import { openConfirmDialog } from "alchemy_admin/confirm_dialog"

// Web Components
import "alchemy_admin/components"

// Handlebars Templates
import "alchemy_admin/templates/compiled"

// Shoelace Setup
import "alchemy_admin/shoelace_theme"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  closeCurrentDialog,
  currentDialog,
  ...Dirty,
  t: translate, // Global utility method for translating a given string
  FixedElements,
  growl,
  LinkDialog,
  pleaseWaitOverlay,
  Spinner,
  reloadPreview
})

Rails.start()
Turbo.config.forms.confirm = openConfirmDialog
document.addEventListener("turbo:load", Initializer)

// Public API for extensions
export { RemoteSelect } from "alchemy_admin/components/remote_select"
export { on } from "alchemy_admin/utils/events"

// Page-specific modules - bundled to avoid dual-loading
export { default as ImageCropper } from "alchemy_admin/image_cropper"
export { default as ImageOverlay } from "alchemy_admin/image_overlay"
export { default as pictureSelector } from "alchemy_admin/picture_selector"
export { default as NodeTree } from "alchemy_admin/node_tree"
