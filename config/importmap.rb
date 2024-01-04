pin "@ungap/custom-elements", to: "https://ga.jspm.io/npm:@ungap/custom-elements@1.3.0/index.js", preload: true
pin "flatpickr", to: "https://ga.jspm.io/npm:flatpickr@4.6.13/dist/esm/index.js", preload: true
pin "lodash-es/max", to: "https://ga.jspm.io/npm:lodash-es@4.17.21/max.js", preload: true
pin "sortablejs", to: "https://ga.jspm.io/npm:sortablejs@1.15.1/modular/sortable.esm.js", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@shoelace/animation-registry", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/utilities/animation-registry.js", preload: true
pin "@shoelace/switch", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/switch/switch.js", preload: true
pin "@shoelace/tab", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/tab/tab.js", preload: true
pin "@shoelace/tab-group", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/tab-group/tab-group.js", preload: true
pin "@shoelace/tab-panel", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/tab-panel/tab-panel.js", preload: true
pin "@shoelace/tooltip", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/tooltip/tooltip.js", preload: true
pin "@shoelace/progress-bar", to: "https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.12.0/cdn/components/progress-bar/progress-bar.js", preload: true
pin "@rails/ujs", to: "https://ga.jspm.io/npm:@rails/ujs@7.1.2/app/assets/javascripts/rails-ujs.esm.js"

pin "alchemy_admin", to: "alchemy_admin.js", preload: true
pin_all_from File.expand_path("../app/javascript/alchemy_admin", __dir__), under: "alchemy_admin"
