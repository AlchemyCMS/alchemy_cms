import AlchemyContentError from "./content_error"

export default {
  components: {
    AlchemyContentError
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_file">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <div class="file">
        <div class="file_icon" v-if="attachment">
          <i :class="iconClasses"></i>
        </div>
        <a @click="assignFile" class="file_icon" :title="'assign_file' | translate" v-else>
          <i class="icon far fa-file fa-fw"></i>
        </a>
        <div class="file_name">
          <span v-if="attachment_id">{{attachment.name}}</span>
          <span v-else>&#x2190; {{ 'assign_file_from_archive' | translate }}</span>
        </div>
        <div class="essence_file_tools">
          <a @click="assignFile" :title="'assign_file' | translate">
            <i class="icon far fa-file fa-fw"></i>
          </a>
          <a @click="editFile" :title="'edit_file_properties' | translate">
            <i class="icon fas fa-edit fa-fw"></i>
          </a>
        </div>
        <input type="hidden" :name="content.form_field_name" v-model="attachment_id">
      </div>
      <alchemy-content-error :content="content"></alchemy-content-error>
    </div>
  `,

  data() {
    const essence = this.content.essence
    return {
      editUrl: "",
      essence: essence
    }
  },

  computed: {
    iconClasses() {
      if (this.attachment) {
        return `icon far fa-${this.attachment.icon_css_class} fa-fw`
      } else {
        return "icon far fa-file fa-fw"
      }
    },

    attachment() {
      const element = this.$store.state.elements.find(
          (element) => element.id === this.content.element_id
        ),
        content = element.contents.find(
          (content) => content.id === this.content.id
        )
      return this.content.essence.essence_file.attachment
    },

    attachment_id() {
      if (this.attachment) {
        return this.attachment.id
      }
    }
  },

  methods: {
    assignFile() {
      let url = Alchemy.routes.admin_attachments_path(this.content.id)
      Alchemy.openDialog(url, {
        title: Alchemy.t("assign_file"),
        size: "780x585",
        padding: false
      })
    },

    editFile() {
      let url = Alchemy.routes.edit_admin_essence_file_path(this.essence.id)
      Alchemy.openDialog(url, {
        size: "400x215",
        title: Alchemy.t("edit_file_properties")
      })
    }
  }
}
