pin "@ungap/custom-elements", to: "ungap-custom-elements.min.js", preload: true # @1.3.0
pin "clipboard", to: "clipboard.min.js", preload: true
pin "cropperjs", to: "cropperjs.min.js", preload: true
pin "flatpickr", to: "flatpickr.min.js", preload: true # @4.6.13
pin "handlebars", to: "handlebars.min.js", preload: true # @4.7.8
pin "jquery", to: "jquery.min.js", preload: true
pin "keymaster", to: "keymaster.min.js", preload: true
pin "select2", to: "select2.min.js", preload: true
pin "sortablejs", to: "sortable.min.js", preload: true # @1.15.1
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "shoelace", to: "shoelace.min.js", preload: true
pin "@rails/ujs", to: "rails-ujs.min.js", preload: true # @7.1.2
pin "tinymce", to: "tinymce.min.js", preload: true

pin "alchemy_admin", to: "alchemy/alchemy_admin.min.js", preload: true
# Individually importable admin components. These resolve to their source
# files (not the bundle) so host engines can import a single component without
# loading and executing the whole admin bundle. Not preloaded, so they add no
# fetches to normal admin page loads (which import the bundle instead).
pin "alchemy_admin/components/page_select"
pin "alchemy_admin/components/attachment_select"
pin "alchemy_admin/components/element_select"
pin "alchemy_admin/components/tags_autocomplete"
pin "alchemy_admin/components/tinymce"
pin "alchemy_admin/components/remote_select"
pin "alchemy_admin/components/select"
pin "alchemy_admin/i18n"
pin "alchemy_admin/image_cropper", to: "alchemy/alchemy_admin.min.js"
pin "alchemy_admin/image_overlay", to: "alchemy/alchemy_admin.min.js"
pin "alchemy_admin/picture_selector", to: "alchemy/alchemy_admin.min.js"
pin "alchemy_admin/node_tree", to: "alchemy/alchemy_admin.min.js"
pin "alchemy_admin/utils/events", to: "alchemy/alchemy_admin.min.js"
