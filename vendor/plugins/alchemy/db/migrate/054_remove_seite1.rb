class RemoveSeite1 < ActiveRecord::Migration
  def self.up
    p = WaPage.find_by_urlname("seite1")
    if !p.nil?
      p.destroy
    end
  end

  def self.down
    root = WaPage.find_by_urlname "startseite"
    demo = WaPage.new
    demo.name = "Seite1"
    demo.urlname = "seite1"
    demo.public = true
    demo.visible = true
    demo.save!
    demo.move_to_child_of root
    demo.save!
  end
end
