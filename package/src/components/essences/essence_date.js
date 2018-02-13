import AlchemyDatePicker from "../datepicker"
import AlchemyContentLabel from "./content_label"

export default {
  components: {
    AlchemyContentLabel,
    AlchemyDatePicker
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_date">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <alchemy-datepicker
        :current="ingredient"
        :name="content.form_field_name"
        :id="content.form_field_id"></alchemy-datepicker>
      <label :for="content.form_field_id" class="essence_date--label">
        <i class="icon far fa-calendar-alt fa-fw fa-lg"></i>
      </label>
    </div>
  `,

  data() {
    return {
      ingredient: this.content.ingredient
    }
  }
}
