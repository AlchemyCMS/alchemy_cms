import "@hotwired/turbo-rails"

import translate from "./alchemy_admin/i18n"
import translationData from "./alchemy_admin/translations"
import fileEditors from "./alchemy_admin/file_editors"
import IngredientAnchorLink from "./alchemy_admin/ingredient_anchor_link"
import pictureEditors from "./alchemy_admin/picture_editors"
import ImageLoader from "./alchemy_admin/image_loader"
import ImageCropper from "./alchemy_admin/image_cropper"
import Datepicker from "./alchemy_admin/datepicker"
import Sitemap from "./alchemy_admin/sitemap"
import Tinymce from "./alchemy_admin/tinymce"
import PagePublicationFields from "./alchemy_admin/page_publication_fields.js"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  // Global utility method for translating a given string
  t: translate,
  translations: Object.assign(Alchemy.translations || {}, translationData),
  fileEditors,
  pictureEditors,
  ImageLoader: ImageLoader.init,
  ImageCropper,
  IngredientAnchorLink,
  Datepicker,
  Sitemap,
  Tinymce,
  PagePublicationFields
})
