export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_file">
      <label :for="content.form_field_id">{{ content.label }}</label>
      <input type="file" :value="content.ingredient" :id="content.form_field_id" :name="content.form_field_name">
    </div>
  `
}
