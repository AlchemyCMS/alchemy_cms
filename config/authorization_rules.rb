authorization do
  
  role :guest do
    has_permission_on :pages, :to => [:show] do
      if_attribute :public => true, :restricted => false
    end
    has_permission_on :elements, :to => [:show] do
      if_attribute :public => true
    end
    has_permission_on :images, :to => [:show]
  end
  
  role :registered do
    includes :guest
    has_permission_on :pages, :to => [:show] do
      if_attribute :public => true
    end
    has_permission_on :users, :to => [:edit, :update] do
      if_attribute :id => is {user.id}
    end
  end
  
  role :author do
    includes :registered
    has_permission_on :admin, :to => [:login_to]
    has_permission_on :pages, :to => [:index, :fold, :edit_content]
    has_permission_on :elements, :to => [:manage_elements]
    has_permission_on :images, :to => [:index, :archive_overlay, :thumb, :show_in_window]
    has_permission_on :attachements, :to => [:index, :archive_overlay]
    has_permission_on :contents, :to => [:manage_atoms]
    has_permission_on :content_pictures, :to => [:manage_picture_atoms]
    has_permission_on :content_files, :to => [:manage_file_atoms]
    has_permission_on :users, :to => [:index]
  end
  
  role :editor do
    includes :author
    has_permission_on :attachements, :to => [:manage]
    has_permission_on :images, :to => [:manage]
    has_permission_on :pages, :to => [:manage_pages]
  end
  
  role :admin do
    includes :editor
    has_permission_on :users, :to => [:manage]
    has_permission_on :authorization_rules, :to => :read
  end
  
end

privileges do
  
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end
  
  privilege :manage_pages, :pages do
    includes :manage, :switch_language, :create_language, :layoutpages, :move, :edit_content
  end
  
  privilege :manage_elements, :elements do
    includes :manage, :copy_to_clipboard, :order, :toggle_fold
  end
  
  privilege :manage_atoms, :contents do
    includes :manage, :order
  end
  
  privilege :manage_picture_atoms, :content_pictures do
    includes :manage, :save_link, :assign
  end
  
  privilege :manage_file_atoms, :content_files do
    includes :manage, :assign
  end
  
  privilege :edit_content, :pages do
    includes :edit_content, :unlock, :preview, :publish
  end
  
  privilege :login_to, :admin do
    includes :index, :login, :logout
  end
  
end
