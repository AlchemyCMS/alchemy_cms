import AlchemyAddEssenceLink from "./add_link"
import AlchemyContentError from "./content_error"
import AlchemyContentLabel from "./content_label"
import AlchemyRemoveEssenceLink from "./remove_link"

export default {
  components: {
    AlchemyAddEssenceLink,
    AlchemyContentError,
    AlchemyContentLabel,
    AlchemyRemoveEssenceLink
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_text">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <input type="text" v-model="ingredient" :name="content.form_field_name" :id="content.form_field_id">
      <alchemy-content-error :content="content"></alchemy-content-error>
      <span class="linkable_essence_tools" v-if="content.settings.linkable">
        <alchemy-add-essence-link
          :essence="essence"
          :content-id="content.id"
          link-class="icon_button"></alchemy-add-essence-link>
        <alchemy-remove-essence-link
          :essence="essence"
          link-class="icon_button"></alchemy-remove-essence-link>
      </span>
    </div>
  `,

  data() {
    return {
      essence: this.content.essence,
      ingredient: this.content.ingredient
    }
  }
}
