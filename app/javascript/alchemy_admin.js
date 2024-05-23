import "@ungap/custom-elements"
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"

import GUI from "alchemy_admin/gui"
import { translate } from "alchemy_admin/i18n"
import Dirty from "alchemy_admin/dirty"
import * as FixedElements from "alchemy_admin/fixed_elements"
import { growl } from "alchemy_admin/growler"
import ImageLoader from "alchemy_admin/image_loader"
import ImageCropper from "alchemy_admin/image_cropper"
import Initializer from "alchemy_admin/initializer"
import { LinkDialog } from "alchemy_admin/link_dialog"
import pictureSelector from "alchemy_admin/picture_selector"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import Sitemap from "alchemy_admin/sitemap"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"
import { reloadPreview } from "alchemy_admin/components/preview_window"
import {
  openConfirmDialog,
  confirmToDeleteDialog
} from "alchemy_admin/confirm_dialog"

// Web Components
import "alchemy_admin/components"

// Shoelace Setup
import "alchemy_admin/shoelace_theme"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  ...Dirty,
  GUI,
  t: translate, // Global utility method for translating a given string
  FixedElements,
  growl,
  ImageLoader: ImageLoader.init,
  ImageCropper,
  LinkDialog,
  pictureSelector,
  pleaseWaitOverlay,
  Sitemap,
  Spinner,
  PagePublicationFields,
  reloadPreview,
  openConfirmDialog,
  confirmToDeleteDialog
})

Rails.start()

$(document).on("turbo:load", Initializer)
