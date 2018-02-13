import AddLink from "./add_link"
import AlchemyContentLabel from "./content_label"
import RemoveLink from "./remove_link"

export default {
  components: {
    AddLink,
    AlchemyContentLabel,
    RemoveLink
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_link">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <input type="text" :value="essence.link" class="text_with_icon disabled" disabled>
      <span class="linkable_essence_tools">
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
      essence: this.content.essence.essence_link
    }
  }
}
