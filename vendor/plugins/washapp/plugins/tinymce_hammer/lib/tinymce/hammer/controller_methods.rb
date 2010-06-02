module Tinymce::Hammer::ControllerMethods

  def self.included base
    base.send(:hide_action, :require_tinymce_hammer)
    base.send(:helper_method, :require_tinymce_hammer)
    base.send(:hide_action, :tinymce_hammer_required?)
    base.send(:helper_method, :tinymce_hammer_required?)
  end

  def require_tinymce_hammer
    @tinymce_hammer_required = true
  end

  def tinymce_hammer_required?
    @tinymce_hammer_required == true
  end

end
