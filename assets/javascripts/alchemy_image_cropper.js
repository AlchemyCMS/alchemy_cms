// Alchemy Wrapperclass for jsCropperUI from David Spurr (http://www.defusion.org.uk/)
var AlchemyImageCropper = Class.create({
  
  initialize: function(element) {
    var defaults = {
      onEndCrop: function (coords, dimensions) {
        var crop_from_field = $('essence_picture_crop_from');
        var crop_size_field = $('essence_picture_crop_size');
        if (crop_from_field && crop_size_field) {
          crop_from_field.value = coords.x1 + "x" + coords.y1;
          crop_size_field.value = dimensions.width + "x" + dimensions.height;
        }
      }
    };
    var options = Object.extend(defaults, arguments[1] || { });
    this.options = options;
    this.element = $(element);
    new Cropper.Img( 
      this.element,
      Object.extend(this.options, {
        onEndCrop: this.options.onEndCrop,
        displayOnInit: true
      }) 
    );
  }

});
