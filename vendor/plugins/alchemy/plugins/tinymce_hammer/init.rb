ActionController::Base.send(:include, Tinymce::Hammer::ControllerMethods)
ActionView::Base.send(:include, Tinymce::Hammer::ViewHelpers)
ActionView::Helpers::FormBuilder.send(:include, Tinymce::Hammer::BuilderMethods)
