export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
    <label :for="content.form_field_id">
      {{ content.label }}
      <span class="validation_indicator" v-if="content.validations.length">*</span>
    </label>
  `
}
