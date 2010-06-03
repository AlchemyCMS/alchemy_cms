class CreateDefaultLanguageRootPage < ActiveRecord::Migration
  def self.up
    WaPage.reset_column_information
    # setting old root to new language root page
    old_root = WaPage.root
    default_language = WaConfigure.parameter(:default_language)
    old_root.language_root_for = default_language
    old_root.language = default_language
    old_root.save
    # creating new root page and move old one as child of it
    new_root_page = WaPage.create(
      :name => "Root",
      :layout => "root",
      :do_not_autogenerate => true
    )
    old_root.move_to_child_of new_root_page
    # setting language of all children to default language
    old_root.descendants.each do |child|
      child.language = default_language
      child.save
    end
  end

  def self.down
    # setting language root page to new root
    default_language = WaConfigure.parameter(:default_language)
    old_root = WaPage.language_root(default_language)
    old_root.language_root_for = nil
    old_root.language = nil
    old_root.parent_id = nil
    old_root.save
    # removing old root
    new_root_page = WaPage.find_by_name("Root")
    new_root_page.destroy
  end
end
