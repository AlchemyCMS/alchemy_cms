export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
  <div class="content-errors">
    <small class="error" v-for="error in content.validation_errors">
      {{error}}
    </small>
  </div>
  `
}
