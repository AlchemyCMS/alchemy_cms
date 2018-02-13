import AlchemyDatePicker from "../datepicker"

export default {
  components: { AlchemyDatePicker },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_date">
      <label>{{ content.label }}</label>
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
