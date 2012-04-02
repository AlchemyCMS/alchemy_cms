# Define permissions for your plugin in here.
# See https://github.com/stffn/declarative_authorization for further informations.
authorization do

  role :guest do
    has_permission_on :<%= @plugin_name.tableize %>, :to => [:show]
  end

  role :registered do
    includes :guest
  end

  role :author do
    includes :registered
  end

  role :editor do
    includes :author
  end

  role :admin do
    includes :editor
    has_permission_on :admin_<%= @plugin_name.tableize %>, :to => [:manage]
  end

end

privileges do

  privilege :manage do
    includes :index, :new, :create, :show, :edit, :update, :destroy
  end

end
