import { RemoteSelect } from "alchemy_admin/components/remote_select"

export class AttachmentSelect extends RemoteSelect {
  _entry(attachment, term) {
    return {
      icon: attachment.icon_css_class,
      primary: this._hightlightTerm(attachment.name, term)
    }
  }

  _selectedEntry(attachment) {
    return {
      icon: attachment.icon_css_class,
      primary: attachment.name
    }
  }
}

customElements.define("alchemy-attachment-select", AttachmentSelect)
