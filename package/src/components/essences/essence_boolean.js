import AlchemyContentError from "./content_error"

export default {
  components: {
    AlchemyContentError
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_boolean">
      <label>
        <input type="hidden" value="0" :name="content.form_field_name">
        <input type="checkbox" :value="defaultValue" v-model="checked" :name="content.form_field_name">
        {{ content.label }}
        <span class="validation_indicator" v-if="content.validations.length">*</span>
      </label>
      <alchemy-content-error :content="content"></alchemy-content-error>
    </div>
  `,

  data() {
    return {
      defaultValue: this.content.settings.default_value || "1",
      checked: this.content.ingredient
    }
  }
}
