import "@hotwired/turbo-rails"

import Buttons from "alchemy_admin/buttons"
import GUI from "alchemy_admin/gui"
import translate from "alchemy_admin/i18n"
import Dirty from "alchemy_admin/dirty"
import translationData from "alchemy_admin/translations"
import fileEditors from "alchemy_admin/file_editors"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import pictureEditors from "alchemy_admin/picture_editors"
import ImageLoader from "alchemy_admin/image_loader"
import ImageCropper from "alchemy_admin/image_cropper"
import Initializer from "alchemy_admin/initializer"
import pictureSelector from "alchemy_admin/picture_selector"
import pleaseWaitOverlay from "alchemy_admin/please_wait_overlay"
import Sitemap from "alchemy_admin/sitemap"
import SelectBox from "alchemy_admin/select_box"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"

// Setting jQueryUIs global animation duration to something more snappy
$.fx.speeds._default = 400

// Web Components
import "alchemy_admin/components/char_counter"
import "alchemy_admin/components/datepicker"
import "alchemy_admin/components/overlay"
import "alchemy_admin/components/page_select"
import "alchemy_admin/components/spinner"
import "alchemy_admin/components/tinymce"
import "alchemy_admin/components/tooltip"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  Buttons,
  ...Dirty,
  GUI,
  t: translate, // Global utility method for translating a given string
  translations: Object.assign(Alchemy.translations || {}, translationData),
  fileEditors,
  pictureEditors,
  ImageLoader: ImageLoader.init,
  ImageCropper,
  Initializer,
  IngredientAnchorLink,
  pictureSelector,
  pleaseWaitOverlay,
  SelectBox,
  Sitemap,
  Spinner,
  PagePublicationFields
})

$(document).on("turbo:load", Initializer)
