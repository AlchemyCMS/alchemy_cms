class CreateSystemPages < ActiveRecord::Migration
  def self.up
    add_column(:pages, :systempage, :boolean, :default => false)
    Page.reset_column_information
    root = Page.root
    systemroot = Page.create(
      :name => "Systemroot",
      :urlname => "systemroot",
      :systempage => true,
      :sitemap => false,
      :do_not_autogenerate => true
    )
    systemroot.move_to_child_of root
    header = Page.create(
      :name => "Header",
      :urlname => "system_header",
      :systempage => true,
      :sitemap => false,
      :layout => "systempage",
      :do_not_autogenerate => true
    )
    header.move_to_child_of systemroot
    footer = Page.create(
      :name => "Footer",
      :urlname => "system_footer",
      :systempage => true,
      :sitemap => false,
      :layout => "systempage",
      :do_not_autogenerate => true
    )
    footer.move_to_child_of systemroot
  end

  def self.down
    Page.reset_column_information
    Page.find_by_name_and_systempage("Header", true).destroy
    Page.find_by_name_and_systempage("Footer", true).destroy
    Page.find_by_name_and_systempage("Systemroot", true).destroy
    remove_column(:pages, :systempage)
  end
end
