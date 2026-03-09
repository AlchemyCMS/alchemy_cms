---
prev: false
next: false
---

# Library

The library is Alchemy's media management module. It stores **pictures** (images) and **attachments** (downloadable files) that editors use in page content.

## Pictures

Pictures are images that editors assign to [Picture ingredients](ingredients#picture) on elements. Alchemy stores the original image and generates resized variants on the fly. See [Rendering Images](render_images) for details on how images are processed and displayed.

The picture library supports:

- Uploading single or multiple images at once
- Tagging pictures for organization
- Language-specific descriptions and captions
- Filtering by file format, tags, or upload date
- Built-in image cropping tool

::: tip
Pictures that are assigned to elements cannot be deleted. Remove them from all elements first.
:::

## Attachments

Attachments are downloadable files like PDFs, documents, or archives. Editors assign them to [File ingredients](ingredients#file) on elements.

The attachment library supports:

- Uploading single or multiple files at once
- Tagging files for organization
- Filtering by file type, tags, or upload date
- Replacing a file while keeping the same record and URL

## Remote storage

In production you typically store media on a remote service like Amazon S3 instead of the local filesystem. See [Rendering Images: Remote storage](render_images#remote-storage) for setup instructions.

## Upload settings

Configure allowed file types and size limits in the [initializer](configuration#uploads).
