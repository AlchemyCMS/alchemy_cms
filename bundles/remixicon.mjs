import fs from "node:fs"
import path from "node:path"
import SVGSpriter from "svg-sprite"
import { consola } from "consola"

const icons = [
  "Arrows/arrow-down-line",
  "Arrows/arrow-down-s-line",
  "Arrows/arrow-left-right-line",
  "Arrows/arrow-left-s-line",
  "Arrows/arrow-left-wide-line",
  "Arrows/arrow-right-s-line",
  "Arrows/arrow-right-wide-line",
  "Arrows/arrow-up-line",
  "Arrows/contract-right-line",
  "Arrows/contract-up-down-line",
  "Arrows/expand-left-line",
  "Arrows/expand-right-line",
  "Arrows/skip-left-line",
  "Arrows/skip-right-line",
  "Buildings/home-2-line",
  "Business/archive-drawer-line",
  "Business/bookmark-fill",
  "Business/bookmark-line",
  "Business/calendar-line",
  "Business/cloud-line",
  "Business/cloud-off-line",
  "Business/global-line",
  "Business/mail-line",
  "Business/profile-line",
  "Business/shake-hands-line",
  "Business/stack-line",
  "Business/window-line",
  "Design/crop-line",
  "Design/edit-line",
  "Design/eraser-line",
  "Design/palette-line",
  "Design/pencil-ruler-2-line",
  "Design/scissors-cut-line",
  "Design/table-line",
  "Development/bug-line",
  "Device/computer-line",
  "Document/article-line",
  "Document/book-3-line",
  "Document/clipboard-fill",
  "Document/clipboard-line",
  "Document/file-3-line",
  "Document/file-add-line",
  "Document/file-cloud-line",
  "Document/file-copy-line",
  "Document/file-edit-line",
  "Document/file-excel-2-line",
  "Document/file-forbid-line",
  "Document/file-image-line",
  "Document/file-line",
  "Document/file-music-line",
  "Document/file-pdf-2-line",
  "Document/file-ppt-2-line",
  "Document/file-text-line",
  "Document/file-upload-line",
  "Document/file-video-line",
  "Document/file-word-2-line",
  "Document/file-zip-line",
  "Document/folder-line",
  "Document/folder-open-line",
  "Document/newspaper-line",
  "Document/pages-line",
  "Editor/draggable",
  "Editor/link-m",
  "Editor/link-unlink-m",
  "Editor/sort-asc",
  "Editor/sort-desc",
  "Editor/translate-2",
  "Finance/price-tag-3-line",
  "Finance/shopping-cart-line",
  "Finance/ticket-line",
  "Media/camera-line",
  "Media/image-add-line",
  "Media/image-line",
  "System/add-line",
  "System/alert-line",
  "System/check-line",
  "System/checkbox-multiple-line",
  "System/close-line",
  "System/delete-bin-2-line",
  "System/download-2-line",
  "System/external-link-line",
  "System/information-line",
  "System/lock-line",
  "System/lock-unlock-line",
  "System/logout-box-r-line",
  "System/menu-2-line",
  "System/menu-add-line",
  "System/menu-fold-line",
  "System/menu-unfold-line",
  "System/more-line",
  "System/more-2-line",
  "System/prohibited-line",
  "System/question-line",
  "System/refresh-line",
  "System/search-line",
  "System/settings-3-line",
  "System/upload-2-line",
  "System/upload-cloud-2-line",
  "System/zoom-in-line",
  "System/zoom-out-line",
  "User & Faces/group-line",
  "User & Faces/user-fill",
  "User & Faces/user-line",
  "User & Faces/robot-2-line"
]

const config = {
  dest: "app/assets/images/alchemy",
  mode: {
    symbol: {
      dest: "",
      sprite: "icons-sprite.svg"
    }
  },
  shape: {
    id: {
      generator: (name) => {
        const id = name.replace(".svg", "")
        return `ri-${id}`
      }
    }
  }
}

const spriter = new SVGSpriter(config)

consola.start(`Building svg sprite of ${icons.length} icons`)

icons.forEach((icon) => {
  const name = icon.replace(/^.+\/(.+)$/, "$1")
  consola.info(`Adding ${name}.svg`)
  spriter.add(
    path.resolve(`node_modules/remixicon/icons/${icon}.svg`),
    `${name}.svg`,
    fs.readFileSync(`node_modules/remixicon/icons/${icon}.svg`, "utf-8")
  )
})

spriter.compile((error, result, _data) => {
  if (error) consola.error(error)

  for (const type of Object.values(result.symbol)) {
    fs.mkdirSync(path.dirname(type.path), { recursive: true })
    consola.success(`Writing ${type.path}`)
    fs.writeFileSync(type.path, type.contents)
  }
})
