import resolve from "@rollup/plugin-node-resolve"
import commonjs from "@rollup/plugin-commonjs"
import terser from "@rollup/plugin-terser"

export default [
  {
    input: "node_modules/clipboard/dist/clipboard.min.js",
    output: {
      file: "vendor/javascript/clipboard.min.js"
    },
    context: "window"
  },
  {
    input: "node_modules/cropperjs/dist/cropper.esm.js",
    output: {
      file: "vendor/javascript/cropperjs.min.js"
    },
    plugins: [terser()],
    context: "window"
  },
  {
    input: "node_modules/flatpickr/dist/esm/index.js",
    output: {
      file: "vendor/javascript/flatpickr.min.js"
    },
    plugins: [resolve(), terser()],
    context: "window"
  },
  {
    input: "node_modules/handlebars/dist/handlebars.min.js",
    output: {
      file: "vendor/javascript/handlebars.min.js"
    },
    context: "window"
  },
  {
    input: "node_modules/jquery/dist/jquery.min.js",
    output: {
      file: "vendor/javascript/jquery.min.js"
    },
    context: "window"
  },
  {
    input: "node_modules/keymaster/keymaster.js",
    output: {
      file: "vendor/javascript/keymaster.min.js"
    },
    plugins: [terser()],
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
    input: "node_modules/select2/select2.min.js",
    output: {
      file: "vendor/javascript/select2.min.js"
    },
    context: "window"
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
  },
  {
    input: "bundles/tinymce.js",
    output: {
      file: "vendor/javascript/tinymce.min.js",
      name: "tinymce",
      format: "esm"
    },
    plugins: [
      resolve({
        modulePaths: ["app/javascript"]
      }),
      commonjs(),
      terser()
    ]
  },
  {
    input: "app/javascript/preview.js",
    output: {
      file: "app/assets/builds/alchemy/preview.min.js"
    },
    context: "window",
    plugins: [terser()]
  }
]
