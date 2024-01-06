import resolve from "@rollup/plugin-node-resolve"

export default {
  input: "bundles/shoelace.js",
  output: {
    file: "vendor/javascript/shoelace.esm.js",
    format: "esm"
  },
  plugins: [resolve()]
}
