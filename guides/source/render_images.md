Render Images
-------------

Alchemy uses [Dragonfly](http://markevans.github.com/dragonfly/) (a
powerful image processing gem) to render images.

Images are stored as master images in the pictury library. The editor
just assigns these master images to content elements you provide. You
also set the image rendering bounderies. The max width and height
values, or even the size an image should be cropped to. Alchemy even
comes with a fancy Javascript based image cropper tool, so that your
customer can define the mask to be used.

endprologue.

### Configuration

-   <code>output\_image\_jpg\_quality</code> <code>[Integer]</code><br>\
     If image gets rendered as JPG this is the quality setting for it.
    (Default <code>85</code>)
-   <code>preprocess\_image\_resize</code> <code>[String]</code><br>\
     Example <code>1000x1000</code>. If you are limited on diskspace use
    this option to downsize large images after upload. (Default
    <code>nil</code>)
-   <code>image\_output\_format</code> <code>[String]</code><br>\
     The global image output format setting. (Default <code>jpg</code>)

INFO: You can always override the output format while rendering your
essence with passing <code>{:format =\> :png}</code> to the
<code>render\_essence</code> helper.

##### The default configuration

<yaml>\
output\_image\_jpg\_quality: 85\
preprocess\_image\_resize:\
image\_output\_format: jpg\
</yaml>

### Rendering

In most cases the <code>render\_essence</code> helper is the perfect fit
for rendering images.\
It handles all advanced stuff for you (Loading the image instance,
setting all needed options and\
sets the correct security token).

INFO: It is <strong>highly recommended</strong> that you use this for
your default image rendering.

#### Rendering Options

-   <code>image\_size</code> <code>String</code><br>\
     The dimensions the image should be resized to, while keeping the
    aspect ratio. Example <code>“400x300”</code>.
-   <code>crop</code> <code>Boolean</code><br>\
     Pass <code>true</code> to crop the image to the given size.
-   <code>format</code> <code>Symbol</code><br>\
     The output format of the image. <code>:jpg</code>,
    <code>:gif</code> or <code>:png</code>.
-   <code>quality</code> <code>Integer</code><br>\
     The quality of the rendered jpg image. Obviously only used on jpg
    images.

#### Advanced rendering

If you want to render an image on your own, please have a look at the
<code>show\_alchemy\_picture\_url</code> helper in the [Alchemy
documentation](http://rubydoc.info/github/magiclabs/alchemy_cms/Alchemy/UrlHelper#show_alchemy_picture_path-instance_method).

### Caching

In production environments all rendered image get cached on disk.

##### If the picture request looks like this:

<code>\
http://example.com/pictures/1/show/name\_of\_image.png?sh=a\_secure\_token\
</code>

##### The image gets stored in this path:

<code>\
/path/to/your/alchemy/app/public/pictures/1/show/name\_of\_image.png\
</code>

NOTE: All supported rendering options are reflected in the url schema.
Even the quality of a rendered jpg image and all cropping options.

INFO: To let Apache serve the images directly, you have to set the
<code>DocumentRoot</code> to the <code>public</code> folder of your
Alchemy app.

### Security

Alchemy has build in DDOS security for rendering images. So you have to
pass a <code>sh</code> parameter and the pictures security token with
every image rendering request.

You can get the security token from a picture with the
<code>security\_token</code> method on a <code>Alchemy::Picture</code>
instance.

<ruby>\
@picture.security\_token(:image\_size =\> “300x400”, :crop =\> true)\
</ruby>

INFO: The <code>render\_essence</code> and
<code>show\_alchemy\_picture\_params</code> helpers set the security
token for you.

.
