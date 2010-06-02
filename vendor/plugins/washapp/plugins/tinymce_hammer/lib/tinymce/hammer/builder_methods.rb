module Tinymce::Hammer::BuilderMethods

  def tinymce method, options = {}
    @template.require_tinymce_hammer
    @template.append_class_name(options, 'tinymce')
    self.text_area(method, options)
  end
  
end
