// We still use jQuery in some places (ie. select2)
import "handlebars"
import "jquery"
import "@ungap/custom-elements"
import "@hotwired/turbo-rails"
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
import Sitemap from "alchemy_admin/sitemap"
import Spinner from "alchemy_admin/spinner"
import PagePublicationFields from "alchemy_admin/page_publication_fields"
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
  Sitemap,
  Spinner,
  PagePublicationFields,
  reloadPreview
})

Rails.start()
Turbo.config.forms.confirm = openConfirmDialog
$(document).on("turbo:load", Initializer)
