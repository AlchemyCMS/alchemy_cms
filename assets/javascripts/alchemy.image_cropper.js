if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {
  
  var ImageCropper = {};
  ImageCropper.initialized = false;
  $.extend(Alchemy, ImageCropper);
  
  Alchemy.ImageCropper = {
    
    init : function (box, size_x, size_y, default_box) {
      var crop_from_field = $('#essence_picture_crop_from');
      var crop_size_field = $('#essence_picture_crop_size');
      var options = {
        onSelect: function(coords) {
          crop_from_field.val(coords.x + "x" + coords.y);
          crop_size_field.val(coords.w + "x" + coords.h);
        },
        setSelect: box,
        aspectRatio: size_x / size_y,
        minSize: [size_x, size_y]
      };
      Alchemy.ImageCropper.box = box;
      Alchemy.ImageCropper.default_box = default_box;
      Alchemy.ImageCropper.crop_from_field = crop_from_field;
      Alchemy.ImageCropper.crop_size_field = crop_size_field;
      
      if (!Alchemy.ImageCropper.initialized) {
        Alchemy.ImageCropper.api = $.Jcrop('#imageToCrop', options);
        Alchemy.ImageCropper.initialized = true;
      }
      
      $('#image_cropper_form').submit(Alchemy.ImageCropper.destroy);
      $('.ui-dialog-titlebar-close').click(Alchemy.ImageCropper.destroy);
    },
    
    undo : function() {
      Alchemy.ImageCropper.api.setSelect(Alchemy.ImageCropper.box);
    },
    
    reset : function() {
      Alchemy.ImageCropper.api.setSelect(Alchemy.ImageCropper.default_box);
      Alchemy.ImageCropper.crop_from_field.val('');
      Alchemy.ImageCropper.crop_size_field.val('');
    },
    
    destroy : function() {
      Alchemy.ImageCropper.api.destroy();
      Alchemy.ImageCropper.initialized = false;
    }
    
  }
  
})(jQuery);
