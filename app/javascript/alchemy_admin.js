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
import Sitemap from "alchemy_admin/sitemap"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"

// Web Components
/**
 * Polyfill to support web components that are customized build in elements. Safari is currently not supporting that
 * web component specification. It is pretty unlikely that Apple will support that feature in the near future. They are
 * against that topic for quite a while.
 * @link https://lists.w3.org/Archives/Public/public-webapps/2013OctDec/0805.html
 * @link https://developer.mozilla.org/en-US/docs/Web/API/CustomElementRegistry/define#customized_built-in_element
 */
const isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent)
if (isSafari) {
  import("@ungap/custom-elements")
}

// use the import(...) instead of import "..." - syntax to wait for the Safari import promise to resolve
import("alchemy_admin/components/char_counter")
import("alchemy_admin/components/tinymce")
import("alchemy_admin/components/tooltip")
import("alchemy_admin/components/datepicker")
import("alchemy_admin/components/spinner")

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
  Sitemap,
  Spinner,
  PagePublicationFields
})

$(document).on("turbo:load", Initializer)
