import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

export default [
  {
    input: "node_modules/flatpickr/dist/esm/index.js",
    output: {
      file: "vendor/javascript/flatpickr.min.js"
    },
    plugins: [resolve(), terser()],
    context: "window"
  },
  {
    input: "node_modules/sortablejs/modular/sortable.esm.js",
    output: {
      file: "vendor/javascript/sortable.min.js"
    },
    plugins: [terser()]
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
      file: "vendor/javascript/rails-ujs.min.js"
    },
    plugins: [terser()]
  },
  {
    input: "bundles/shoelace.js",
    output: {
      file: "vendor/javascript/shoelace.min.js"
    },
    plugins: [resolve(), terser()]
  }
]
