authorization do
  
  role :guest do
    has_permission_on :wa_pages, :to => [:show] do
      if_attribute :public => true, :restricted => false
    end
    has_permission_on :wa_molecules, :to => [:show] do
      if_attribute :public => true
    end
    has_permission_on :wa_images, :to => [:show]
  end
  
  role :registered do
    includes :guest
    has_permission_on :wa_pages, :to => [:show] do
      if_attribute :public => true
    end
    has_permission_on :wa_users, :to => [:edit, :update] do
      if_attribute :id => is {user.id}
    end
  end
  
  role :author do
    includes :registered
    has_permission_on :washapp, :to => [:login_to]
    has_permission_on :wa_pages, :to => [:index, :fold, :edit_content]
    has_permission_on :wa_molecules, :to => [:manage_molecules]
    has_permission_on :wa_images, :to => [:index, :archive_overlay, :thumb, :show_in_window]
    has_permission_on :wa_files, :to => [:index, :archive_overlay]
    has_permission_on :wa_atoms, :to => [:manage_atoms]
    has_permission_on :wa_atom_pictures, :to => [:manage_picture_atoms]
    has_permission_on :wa_atom_files, :to => [:manage_file_atoms]
    has_permission_on :wa_users, :to => [:index]
  end
  
  role :editor do
    includes :author
    has_permission_on :wa_files, :to => [:manage]
    has_permission_on :wa_images, :to => [:manage]
    has_permission_on :wa_pages, :to => [:manage_pages]
  end
  
  role :admin do
    includes :editor
    has_permission_on :wa_users, :to => [:manage]
    has_permission_on :authorization_rules, :to => :read
  end
  
end

privileges do
  
  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end
  
  privilege :manage_pages, :wa_pages do
    includes :manage, :switch_language, :create_language, :systempages, :move, :edit_content
  end
  
  privilege :manage_molecules, :wa_molecules do
    includes :manage, :copy_to_clipboard, :order, :toggle_fold
  end
  
  privilege :manage_atoms, :wa_atoms do
    includes :manage, :order
  end
  
  privilege :manage_picture_atoms, :wa_atom_pictures do
    includes :manage, :save_link, :assign
  end
  
  privilege :manage_file_atoms, :wa_atom_files do
    includes :manage, :assign
  end
  
  privilege :edit_content, :wa_pages do
    includes :edit_content, :unlock, :preview, :publish
  end
  
  privilege :login_to, :washapp do
    includes :index, :login, :logout
  end
  
end
