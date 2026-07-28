// Stub for the "@hotwired/turbo-rails" importmap external. It is not installed
// as a package (see the `external` list in rollup.admin.config.mjs), so vitest
// cannot resolve the real module. This provides just enough of the Turbo API for
// turbo_stream_actions.js to register its custom stream actions under test.
export const Turbo = {
  StreamActions: {},
  visit() {}
}
