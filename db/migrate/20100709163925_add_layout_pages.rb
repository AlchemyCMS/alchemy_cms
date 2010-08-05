class AddLayoutPages < ActiveRecord::Migration
  def self.up
    layoutroot = Page.find_by_name('LayoutRoot')

    header = Page.create(
      :name => 'Layout Header',
      :page_layout => 'layout_header',
      :language => '',
      :do_not_autogenerate => true,
      :layoutpage => true
    )
    header.move_to_child_of layoutroot

    footer = Page.create(
      :name => 'Layout Footer',
      :page_layout => 'layout_footer',
      :language => '',
      :do_not_autogenerate => true,
      :layoutpage => true
    )
    footer.move_to_child_of layoutroot
  end

  def self.down
    header = Page.find_by_name('Layout Header')
    header.destroy if header
    footer = Page.find_by_name('Layout Footer')
    footer.destroy if footer
  end
end
