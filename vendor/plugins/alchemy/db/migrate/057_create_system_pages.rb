class CreateSystemPages < ActiveRecord::Migration
  def self.up
    add_column(:wa_pages, :systempage, :boolean, :default => false)
    WaPage.reset_column_information
    root = WaPage.root
    systemroot = WaPage.create(
      :name => "Systemroot",
      :urlname => "systemroot",
      :systempage => true,
      :sitemap => false,
      :do_not_autogenerate => true
    )
    systemroot.move_to_child_of root
    header = WaPage.create(
      :name => "Header",
      :urlname => "system_header",
      :systempage => true,
      :sitemap => false,
      :layout => "systempage",
      :do_not_autogenerate => true
    )
    header.move_to_child_of systemroot
    footer = WaPage.create(
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
    WaPage.reset_column_information
    WaPage.find_by_name_and_systempage("Header", true).destroy
    WaPage.find_by_name_and_systempage("Footer", true).destroy
    WaPage.find_by_name_and_systempage("Systemroot", true).destroy
    remove_column(:wa_pages, :systempage)
  end
end
