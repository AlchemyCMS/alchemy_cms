class BuildPageStructure < ActiveRecord::Migration
  def self.up
    root = Page.create(
      :name => "Startseite",
      :urlname => "startseite",
      :public => true,
      :visible => true,
      :do_not_autogenerate => true
    )
    demo = Page.create(
      :name => "Seite1",
      :urlname => "seite1",
      :public => true,
      :visible => true,
      :do_not_autogenerate => true
    )
    demo.move_to_child_of root
  end

  def self.down
  end
end
