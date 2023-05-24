import translate from "./src/i18n"
import translationData from "./src/translations"
import NodeTree from "./src/node_tree"
import fileEditors from "./src/file_editors"
import IngredientAnchorLink from "./src/ingredient_anchor_link"
import pictureEditors from "./src/picture_editors"
import ImageLoader from "./src/image_loader"
import ImageCropper from "./src/image_cropper"
import Datepicker from "./src/datepicker"
import Sitemap from "./src/sitemap"
import Tinymce from "./src/tinymce"
import PagePublicationFields from "./src/page_publication_fields.js"

// Global Alchemy object
if (typeof window.Alchemy === "undefined") {
  window.Alchemy = {}
}

// Enhance the global Alchemy object with imported features
Object.assign(Alchemy, {
  // Global utility method for translating a given string
  t: translate,
  translations: Object.assign(Alchemy.translations || {}, translationData),
  NodeTree,
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
