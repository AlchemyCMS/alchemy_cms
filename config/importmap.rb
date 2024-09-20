pin "@ungap/custom-elements", to: "ungap-custom-elements.min.js", preload: true # @1.3.0
pin "clipboard", to: "clipboard.min.js", preload: true
pin "cropperjs", to: "cropperjs.min.js", preload: true
pin "flatpickr", to: "flatpickr.min.js", preload: true # @4.6.13
pin "handlebars", to: "handlebars.min.js", preload: true # @4.7.8
pin "keymaster", to: "keymaster.min.js", preload: true
pin "sortablejs", to: "sortable.min.js", preload: true # @1.15.1
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "shoelace", to: "shoelace.min.js", preload: true
pin "@rails/ujs", to: "rails-ujs.min.js", preload: true # @7.1.2
pin "tinymce", to: "tinymce.min.js", preload: true

pin "alchemy_admin", to: "alchemy_admin.js", preload: true
pin_all_from File.expand_path("../app/javascript/alchemy_admin", __dir__), under: "alchemy_admin", preload: true
