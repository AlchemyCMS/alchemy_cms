class CreateTree < ActiveRecord::Migration
  def self.up
    root = Page.create(
      :name => 'Root',
      :do_not_autogenerate => true
    )
    layoutroot = Page.create(
      :name => 'LayoutRoot',
      :do_not_autogenerate => true,
      :layoutpage => true
    )
    layoutroot.move_to_child_of root
  end
  
  def self.down
    Page.root.destroy
  end
end
