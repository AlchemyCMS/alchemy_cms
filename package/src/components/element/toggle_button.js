export default {
  props: {
    element: { type: Object, required: true }
  },

  template: `
    <a class="ajax-folder"
      :data-element-toggle="element.id"
      @click.prevent="toggle"
      :title="title">
      <i :class="iconClasses"></i>
    </a>
  `,

  computed: {
    iconClasses() {
      const icon = this.element.folded ? "plus" : "minus"
      return `icon fa-fw fa-${icon}-square fas`
    },

    title() {
      const title = this.element.folded
        ? "show_element_content"
        : "hide_element_content"
      return Alchemy.t(title)
    }
  },

  methods: {
    toggle() {
      const id = this.element.id
      const el = $(`#element_${id}`)
      if (Alchemy.isElementDirty(el)) {
        Alchemy.openConfirmDialog(Alchemy.t("element_dirty_notice"), {
          title: Alchemy.t("warning"),
          ok_label: Alchemy.t("ok"),
          cancel_label: Alchemy.t("cancel"),
          on_ok: () => this._toggleFold(id)
        })
        false
      } else {
        this._toggleFold(id)
      }
    },

    _toggleFold(id) {
      const spinner = new Alchemy.Spinner("small")
      const $icon = $(".icon", this.$el)
      spinner.spin(this.$el)
      $icon.hide()
      $.post(Alchemy.routes.fold_admin_element_path(id))
        .always(() => {
          spinner.stop()
          $icon.show()
        })
        .done((data) => {
          const $element = $(
            `.element-editor[data-element-id="${this.element.id}"]`
          )
          this.element.folded = data.folded
          // TODO: Refresh sortable elements after fold element
          // $('#element_area .sortable-elements').sortable('refresh');
          if (data.folded) {
            // TODO: Remove tinymces
            // Alchemy.Tinymce.remove(<%= @element.richtext_contents_ids.to_json %>);
          } else {
            $element.trigger("FocusElementEditor.Alchemy")
            // TODO: Init tinymces
            // Alchemy.Tinymce.init(<%= @element.richtext_contents_ids.to_json %>);
            // TODO: Init element GUI
            // Alchemy.GUI.initElement($el);
            // Alchemy.SortableElements(
            //   <%= @page.id %>,
            //   $('> .nestable-elements .nested-elements', $el)
            // );
          }
        })
        .fail((_jqXHR, _textStatus, errorThrown) => {
          $icon
            .removeClass("fa-minus-square fa-plus-square")
            .addClass("fa-exclamation")
            .attr("title", errorThrown)
        })
    }
  }
}
