export const VERSIONS = [6, 7, 8, 9]
export const CURRENT_VERSION = 8
export const NEXT_VERSION = 9

const FOLDERS = {
  [CURRENT_VERSION]: "",
  [NEXT_VERSION]: "next",
}

export const folderOf = (version) => FOLDERS[version] ?? `v${version}`
