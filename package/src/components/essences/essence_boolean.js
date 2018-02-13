export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_boolean">
      <label style="display: inline">
        <input type="hidden" value="0" :name="content.form_field_name">
        <input type="checkbox" :value="defaultValue" v-model="checked" :name="content.form_field_name">
        {{ content.label }}
      </label>
    </div>
  `,

  data() {
    return {
      defaultValue: this.content.settings.default_value || "1",
      checked: this.content.ingredient
    }
  }
}
