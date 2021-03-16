import AlchemyContentError from "./content_error"
import AlchemyContentLabel from "./content_label"
import AlchemyAddEssenceLink from "./add_link"
import AlchemyRemoveEssenceLink from "./remove_link"

export default {
  components: {
    AlchemyContentError,
    AlchemyContentLabel,
    AlchemyAddEssenceLink,
    AlchemyRemoveEssenceLink
  },

  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_picture">
      <alchemy-content-label :content="content"></alchemy-content-label>
      <div class="picture_thumbnail">
        <span class="picture_tool delete" v-show="picture_id">
          <a @click="removePicture">
            <i class="icon fas fa-times fa-fw"></i>
          </a>
        </span>
        <div class="picture_image">
          <div class="thumbnail_background">
            <img class="img_paddingtop"
              :src="essence.thumbnail_url" v-show="picture_id">
            <i v-show="!picture_id" class="icon far fa-image fa-fw"></i>
          </div>
        </div>
        <div class="edit_images_bottom">
          <a @click="cropPicture" :title="'Edit Picturemask' | translate">
            <i class="icon fas faw fa-crop"></i>
          </a>
          <a @click="assignPicture" :title="assignPictureTitle | translate">
            <i class="icon far faw fa-file-image"></i>
            <input type="hidden"
              :name="content.form_field_name"
              :id="content.form_field_id" v-model="picture_id">
          </a>
          <alchemy-add-essence-link :essence="essence" :content-id="content.id" title="link_image"></alchemy-add-essence-link>
          <alchemy-remove-essence-link :essence="essence"></alchemy-remove-essence-link>
          <a @click="editPicture" :title="'edit_image_properties' | translate">
            <i class="icon fas faw fa-edit"></i>
          </a>
        </div>
      </div>
      <alchemy-content-error :content="content"></alchemy-content-error>
    </div>
  `,

  mounted() {
    const img = this.$el.querySelector(".picture_image img")
    // We set the picture id from the assign image dialog and since
    // Vuejs does not watch for DOM changes we need to update the attribute
    $(this.$el).on("change", `#${this.content.form_field_id}`, (e) => {
      this.picture_id = e.currentTarget.value
    })
    // We set the picture src from the assign image dialog and since
    // Vuejs does not watch for DOM changes we need to update the attribute
    new MutationObserver((mutations) => {
      for (var mutation of mutations) {
        if (mutation.attributeName === "src") {
          this.essence.thumbnail_url = img.getAttribute("src")
          Alchemy.setElementDirty($(this.$el).closest(".element-editor"))
        }
      }
    }).observe(img, { attributes: true })
  },

  data() {
    const essence = this.content.essence
    const picture_id = essence.picture_id
    return {
      essence: essence,
      image: essence.picture,
      picture_id: picture_id,
      assignPictureTitle: picture_id ? "swap_image" : "insert_image"
    }
  },

  methods: {
    removePicture() {
      const $element = $(this.$el).closest(".element-editor")
      this.picture_id = null
      Alchemy.setElementDirty($element)
    },

    cropPicture() {
      let url = Alchemy.routes.crop_admin_essence_picture_path(this.essence.id)
      Alchemy.openDialog(url, {
        size: "1080x615",
        title: Alchemy.t("Edit Picturemask"),
        image_loader: false,
        padding: false
      })
    },

    editPicture() {
      let url = Alchemy.routes.edit_admin_essence_picture_path(this.essence.id)
      Alchemy.openDialog(url, {
        size: "380x255",
        title: Alchemy.t("edit_image_properties")
      })
    },

    assignPicture() {
      let url = Alchemy.routes.admin_pictures_path(this.content.id)
      Alchemy.openDialog(url, {
        title: Alchemy.t(this.assignPictureTitle),
        size: "780x580",
        padding: false
      })
    }
  }
}
