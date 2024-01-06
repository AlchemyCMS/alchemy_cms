pin "@ungap/custom-elements", to: "https://ga.jspm.io/npm:@ungap/custom-elements@1.3.0/index.js", preload: true
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.1/modular/sortable.esm.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "shoelace", to: "shoelace.esm.js", preload: true
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.1.2/app/assets/javascripts/rails-ujs.esm.js", preload: true

pin "alchemy_admin", to: "alchemy_admin.js", preload: true
pin_all_from File.expand_path("../app/javascript/alchemy_admin", __dir__), under: "alchemy_admin", preload: true
