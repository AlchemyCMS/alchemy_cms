import "@ungap/custom-elements"
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"

import GUI from "alchemy_admin/gui"
import { translate } from "alchemy_admin/i18n"
import Dirty from "alchemy_admin/dirty"
import { growl } from "alchemy_admin/growler"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import ImageLoader from "alchemy_admin/image_loader"
import ImageCropper from "alchemy_admin/image_cropper"
import Initializer from "alchemy_admin/initializer"
import { LinkDialog } from "alchemy_admin/link_dialog"
import pictureSelector from "alchemy_admin/picture_selector"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import Sitemap from "alchemy_admin/sitemap"
import SortableElements from "alchemy_admin/sortable_elements"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"
import { reloadPreview } from "alchemy_admin/components/preview_window"

// Web Components
import "alchemy_admin/components"

import { setDefaultAnimation } from "shoelace"

// Change the default animation for all dialogs
setDefaultAnimation("tooltip.show", {
  keyframes: [
    { transform: "translateY(10px)", opacity: "0" },
    { transform: "translateY(0)", opacity: "1" }
  ],
  options: {
    duration: 100
  }
})

setDefaultAnimation("tooltip.hide", {
  keyframes: [
    { transform: "translateY(0)", opacity: "1" },
    { transform: "translateY(10px)", opacity: "0" }
  ],
  options: {
    duration: 100
  }
})

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  ...Dirty,
  GUI,
  t: translate, // Global utility method for translating a given string
  growl,
  ImageLoader: ImageLoader.init,
  ImageCropper,
  IngredientAnchorLink,
  LinkDialog,
  pictureSelector,
  pleaseWaitOverlay,
  Sitemap,
  SortableElements,
  Spinner,
  PagePublicationFields,
  reloadPreview
})

Rails.start()

$(document).on("turbo:load", Initializer)
