---
prev: /essences.html
next: /configuration.html
---

# Render Images

Alchemy uses [Dragonfly](https://markevans.github.io/dragonfly/) to render images.

Images are stored as master images in the pictury library. The editor just assigns these master images to content elements you provide. You also set the image rendering bounderies. The max width and height values, or even the size an image should be cropped to. Alchemy even comes with a built in image cropping tool, so that your editors can define the mask to be used.

## Configuration

* **output_image_jpg_quality** `Integer` (Default `85`)

  If image gets rendered as JPG this is the quality setting for it.

* **preprocess_image_resize** `String` (Default `nil`)

  Example `1000x1000`. If you are limited on diskspace use this option to downsize large images after upload.

* **image_output_format** `String` (Default `jpg`)

  The global image output format setting.

::: tip
You can always override the output format while rendering your essence with passing `{format: 'png'}` to the `el.render(:image)` method.
:::

### The default configuration

~~~ yaml
output_image_jpg_quality: 85
preprocess_image_resize:
image_output_format: jpg
~~~

## Rendering

In most cases the `el.render(:image)` method is the perfect fit for rendering images.

It handles all advanced stuff for you (Loading the image instance, setting all needed options and
sets the correct security token).

### Rendering Options

* **size** `String`

  The dimensions the image should be resized to, while keeping the aspect ratio. Example `"400x300"`.

* **crop** `Boolean`

  Pass `true` to crop the image to the given size.

* **format** `Symbol|String`

  The output format of the image. `:jpg`, `:gif` or `:png`.

* **quality** `Integer`

  The quality of the rendered jpg image. Obviously only used on jpg images.

### Advanced rendering

If you want to render an image on your own, please have a look at the `show_alchemy_picture_url` helper in the [Alchemy documentation](https://www.rubydoc.info/github/AlchemyCMS/alchemy_cms/Alchemy/UrlHelper#show_alchemy_picture_path-instance_method).

## Caching

In production environments you want to implement a cache to avoid rendering the same image over and over again.

All supported rendering options are reflected in the url schema. Even the quality of a rendered jpg image and all cropping options. So adding a CDN or HTTP cache (ie. `Rack::Cache`) is the recommended caching option.

::: tip
Please be sure to read the [Dragonfly caching guide](https://markevans.github.io/dragonfly/cache) for further informations.
:::
