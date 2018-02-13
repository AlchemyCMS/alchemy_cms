export default {
  props: {
    content: { type: Object, required: true }
  },

  template: `
    <div class="essence_picture">
      <label>{{ content.label }}</label>
      <div class="picture_thumbnail">
        <span class="picture_tool delete">
          <a></a>
        </span>
        <div class="picture_image">
          <div class="thumbnail_background">
            <img class="img_paddingtop" :title="image.name" :src="essence.thumbnail_url" v-if="image">
          </div>
        </div>
        <div class="edit_images_bottom">
          <a title="Bildmaske bearbeiten">
            <i class="icon fas faw fa-crop"></i>
          </a>
          <a title="Bild tauschen">
            <i class="icon far faw fa-file-image"></i>
          </a>
          <alchemy-add-essence-link :essence="essence" :content-id="content.id" title="link_image"></alchemy-add-essence-link>
          <alchemy-remove-essence-link :essence="essence"></alchemy-remove-essence-link>
          <a title="Bildeigenschaften bearbeiten">
            <i class="icon fas faw fa-edit"></i>
          </a>
        </div>
      </div>
    </div>
  `,

  data() {
    const essence = this.content.essence.essence_picture
    return {
      essence: essence,
      image: essence.picture
    }
  }
}
