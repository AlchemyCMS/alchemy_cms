import "@hotwired/turbo-rails"

import Buttons from "alchemy_admin/buttons"
import Dialog from "alchemy_admin/dialog"
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
import Sitemap from "alchemy_admin/sitemap"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"

// Web Components
import "alchemy_admin/components/char_counter"
import "alchemy_admin/components/tinymce"
import "alchemy_admin/components/tooltip"
import "alchemy_admin/components/datepicker"
import "alchemy_admin/components/spinner"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  Buttons,
  ...Dialog,
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
  Sitemap,
  Spinner,
  PagePublicationFields
})

$(document).on("turbo:load", Initializer)
