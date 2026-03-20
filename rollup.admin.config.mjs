import resolve from "@rollup/plugin-node-resolve"
import terser from "@rollup/plugin-terser"

export default {
  input: "app/javascript/alchemy_admin.js",
  output: {
    file: "app/assets/builds/alchemy/alchemy_admin.min.js",
    format: "es",
    sourcemap: true
  },
  external: [
    "handlebars",
    "jquery",
    "@ungap/custom-elements",
    "@hotwired/turbo-rails",
    "select2",
    "@rails/ujs",
    "clipboard",
    "cropperjs",
    "flatpickr",
    "keymaster",
    "sortablejs",
    "shoelace",
    "tinymce"
  ],
  plugins: [
    resolve({
      modulePaths: ["app/javascript"]
    }),
    terser()
  ].filter(Boolean)
}
