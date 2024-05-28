import { RemoteSelect } from "alchemy_admin/components/remote_select"

class AttachmentSelect extends RemoteSelect {
  _renderResult(item) {
    return this._renderListEntry(item)
  }

  /**
   * html template for each list entry
   * @param {object} page
   * @param {string} term
   * @returns {string}
   * @private
   */
  _renderListEntry(attachment, term) {
    return `
      <div class="attachment-select--attachment">
        <alchemy-icon name="${attachment.icon_css_class}"></alchemy-icon>
        <span class="attachment-select--attachment-name">${this._hightlightTerm(attachment.name, term)}</span>
      </div>
    `
  }
}

customElements.define("alchemy-attachment-select", AttachmentSelect)
