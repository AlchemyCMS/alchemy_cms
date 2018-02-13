import AlchemyContentError from "./content_error"
import AlchemyContentLabel from "./content_label"

export default {
  components: {
    AlchemyContentError,
    AlchemyContentLabel
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_select">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <select class="alchemy_selectbox full_width" v-model="selected" :name="content.form_field_name" :id="content.form_field_id">
        <option v-for="option in options" :value="option.value">
          {{ option.text }}
        </option>
      </select>
      <alchemy-content-error :content="content"></alchemy-content-error>
    </div>
  `,

  data() {
    const options = this._optionsForSelect(this.content.settings.select_values)
    return {
      selected: this.content.ingredient,
      options: options
    }
  },

  mounted() {
    Alchemy.SelectBox(this.$el)
  },

  methods: {
    _optionsForSelect(options) {
      return options.map(function (option) {
        if (typeof option === "string") {
          return { text: option, value: option }
        } else {
          return option
        }
      })
    }
  }
}
