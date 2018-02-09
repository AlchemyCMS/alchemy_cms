export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `
    <div class="element-footer">
      <p class="validation_notice" v-if="element.has_validations">
        <span class="validation_indicator">*</span>
        {{ 'Mandatory' | translate }}
      </p>

      <button :form="elementForm" @click.prevent.stop="save" type="submit" class="button" data-alchemy-button>
        {{ 'save' | translate }}
      </button>
    </div>
  `,

  data() {
    return {
      elementForm: `element_${this.element.id}_form`
    }
  },

  methods: {
    save(e) {
      const params = $(e.currentTarget.form).serialize()
      Alchemy.Buttons.disable(this.$el.querySelector("button"))
      $.ajax(Alchemy.routes.admin_element_path(this.element.id), {
        type: "POST",
        method: "PUT",
        data: params
      })
        .done(() => {
          Alchemy.growl(Alchemy.t("element_saved"))
          Alchemy.reloadPreview(this.element.id)
          Alchemy.setElementClean(`#element_${this.element.id}`)
        })
        .always(() => {
          Alchemy.Buttons.enable(this.$el.parentElement)
        })
    }
  }
}
