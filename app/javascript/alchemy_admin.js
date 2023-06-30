import "@hotwired/turbo-rails"

import Base from "alchemy_admin/base"
import Buttons from "alchemy_admin/buttons"
import Dialog from "alchemy_admin/dialog"
import GUI from "alchemy_admin/gui"
import Dirty from "alchemy_admin/dirty"
import translate from "alchemy_admin/i18n"
import translationData from "alchemy_admin/translations"
import fileEditors from "alchemy_admin/file_editors"
import IngredientAnchorLink from "alchemy_admin/ingredient_anchor_link"
import pictureEditors from "alchemy_admin/picture_editors"
import ImageLoader from "alchemy_admin/image_loader"
import ImageCropper from "alchemy_admin/image_cropper"
import Initializer from "alchemy_admin/initializer"
import Datepicker from "alchemy_admin/datepicker"
import Sitemap from "alchemy_admin/sitemap"
import Tinymce from "alchemy_admin/tinymce"
import PagePublicationFields from "alchemy_admin/page_publication_fields"

// Setting jQueryUIs global animation duration to something more snappy
$.fx.speeds._default = 400

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  ...Base,
  Buttons,
  ...Dialog,
  GUI,
  ...Dirty,
  t: translate, // Global utility method for translating a given string
  translations: Object.assign(Alchemy.translations || {}, translationData),
  fileEditors,
  pictureEditors,
  ImageLoader: ImageLoader.init,
  ImageCropper,
  Initializer,
  IngredientAnchorLink,
  Datepicker,
  Sitemap,
  Tinymce,
  PagePublicationFields
})

$(document).on("turbo:load", Initializer)

$(document).on("turbo:before-fetch-request", function () {
  Alchemy.Tinymce.removeFrom($(".has_tinymce"))
})
