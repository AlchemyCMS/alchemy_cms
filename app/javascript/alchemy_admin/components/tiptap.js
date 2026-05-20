import { Editor, StarterKit } from "tiptap"
import { LinkDialog } from "alchemy_admin/link_dialog"

const setAlchemyLink = (editor) => {
  const link = editor.getAttributes("link")
  const linkDialog = new LinkDialog({
    url: link.href,
    title: link.title,
    target: link.target,
    type: link.class
  })

  linkDialog.open().then((alchemyLink) => {
    editor
      .chain()
      .focus()
      .extendMarkRange("link")
      .setLink({
        href: alchemyLink.url,
        class: alchemyLink.type,
        title: alchemyLink.title,
        target: alchemyLink.target
      })
      .run()
  })
}

const BUTTONS = {
  bold: {
    cmd: (e) => e.chain().focus().toggleBold().run(),
    active: "bold"
  },
  code: {
    cmd: (e) => e.chain().focus().toggleCode().run(),
    active: "code"
  },
  italic: {
    cmd: (e) => e.chain().focus().toggleItalic().run(),
    active: "italic"
  },
  underline: {
    cmd: (e) => e.chain().focus().toggleUnderline().run(),
    active: "underline"
  },
  strike: {
    cmd: (e) => e.chain().focus().toggleStrike().run(),
    active: "strike"
  },
  blockquote: {
    cmd: (e) => e.chain().focus().toggleBlockquote().run(),
    active: "blockquote"
  },
  bulletList: {
    cmd: (e) => e.chain().focus().toggleBulletList().run(),
    active: "bulletList"
  },
  orderedList: {
    cmd: (e) => e.chain().focus().toggleOrderedList().run(),
    active: "orderedList"
  },
  horizontalRule: {
    cmd: (e) => e.chain().focus().setHorizontalRule().run(),
    active: null
  },
  undo: {
    cmd: (e) => e.chain().focus().undo().run(),
    active: null
  },
  redo: {
    cmd: (e) => e.chain().focus().redo().run(),
    active: null
  },
  unlink: {
    cmd: (e) => e.chain().focus().unsetLink().run(),
    active: null
  },
  alchemyLink: {
    cmd: setAlchemyLink,
    active: "link"
  }
}

class AlchemyTiptap extends HTMLElement {
  connectedCallback() {
    this.input = this.querySelector("textarea")
    this.editorNode = this.querySelector(".tiptap-content")
    this.config = JSON.parse(this.getAttribute("config") || "{}")

    this.initEditor()
  }

  disconnectedCallback() {
    if (this.editor) {
      this.editor.destroy()
      this.editor = null
    }
  }

  async initEditor() {
    const extensions = [StarterKit]

    this.editor = new Editor({
      element: this.editorNode,
      extensions,
      content: this.input?.value || "",
      onUpdate: ({ editor }) => {
        if (this.input) {
          this.input.value = editor.getHTML()
        }
        // Trigger Alchemy's dirty tracking
        this.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })

    this.initToolbar()

    this.editor.on("selectionUpdate", () => this.updateActiveStates())
    this.editor.on("transaction", () => this.updateActiveStates())
  }

  initToolbar() {
    this.buttons = this.querySelectorAll(`[data-tiptap-button]`)
    this.buttons.forEach((btn) => {
      const el = this.initButton(btn.dataset.tiptapButton)
    })
  }

  initButton(name) {
    if (name === "heading") return this.createHeadingSelect()

    const spec = BUTTONS[name]
    if (!spec) return null

    const btn = this.querySelector(`[data-tiptap-button="${name}"]`)
    btn.addEventListener("click", (e) => {
      e.preventDefault()
      spec.cmd(this.editor, this)
    })

    return btn
  }

  createHeadingSelect() {
    const levels = this.config.heading_levels || [2, 3, 4]
    const select = document.createElement("select")
    select.className = "tiptap-toolbar-select"
    select.dataset.tiptapButton = "heading"

    const p = document.createElement("option")
    p.value = "p"
    p.textContent = "¶"
    select.appendChild(p)

    levels.forEach((l) => {
      const opt = document.createElement("option")
      opt.value = `h${l}`
      opt.textContent = `H${l}`
      select.appendChild(opt)
    })

    select.addEventListener("change", () => {
      if (select.value === "p") {
        this.editor.chain().focus().setParagraph().run()
      } else {
        const level = parseInt(select.value.replace("h", ""), 10)
        this.editor.chain().focus().toggleHeading({ level }).run()
      }
    })
    return select
  }

  updateActiveStates() {
    this.buttons.forEach((el) => {
      const name = el.dataset.tiptapButton
      const spec = BUTTONS[name]

      if (spec?.active) {
        el.classList.toggle("is-active", this.editor.isActive(spec.active))
      }

      if (name === "heading" && el.tagName === "SELECT") {
        const active = [1, 2, 3, 4, 5, 6].find((l) =>
          this.editor.isActive("heading", { level: l })
        )
        el.value = active ? `h${active}` : "p"
      }
    })
  }
}

customElements.define("alchemy-tiptap", AlchemyTiptap)
