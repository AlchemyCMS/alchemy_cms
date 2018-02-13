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
    <div class="essence_html">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <textarea v-model="ingredient" :name="content.form_field_name" :id="content.form_field_id">{{content.ingredient}}</textarea>
      <alchemy-content-error :content="content"></alchemy-content-error>
    </div>
  `,

  data() {
    return {
      ingredient: this.content.ingredient
    }
  }
}
