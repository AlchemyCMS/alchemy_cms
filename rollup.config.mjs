import resolve from "@rollup/plugin-node-resolve"

export default [
  {
    input: "node_modules/flatpickr/dist/esm/index.js",
    output: {
      file: "vendor/javascript/flatpickr.esm.js"
    },
    plugins: [resolve()],
    context: "window"
  },
  {
    input: "node_modules/sortablejs/modular/sortable.esm.js",
    output: {
      file: "vendor/javascript/sortable.esm.js"
    }
  },
  {
    input: "node_modules/@ungap/custom-elements/min.js",
    output: {
      file: "vendor/javascript/ungap-custom-elements.min.js"
    }
  },
  {
    input: "node_modules/@rails/ujs/app/assets/javascripts/rails-ujs.esm.js",
    output: {
      file: "vendor/javascript/rails-ujs.esm.js"
    }
  },
  {
    input: "bundles/shoelace.js",
    output: {
      file: "vendor/javascript/shoelace.esm.js",
      format: "esm"
    },
    plugins: [resolve()]
  }
]
