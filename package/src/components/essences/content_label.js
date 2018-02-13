export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `<label :for="content.form_field_id">{{ content.label }}</label>`
}
