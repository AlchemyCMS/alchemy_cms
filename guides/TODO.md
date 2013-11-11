http://guides.alchemy-cms.com/page_layouts.html mit http://guides.alchemy-cms.com/create_page_layouts.html
http://guides.alchemy-cms.com/elements.html mit http://guides.alchemy-cms.com/create_elements.html
http://guides.alchemy-cms.com/essences.html mit http://guides.alchemy-cms.com/create_essences.html
zusammenlegen

Erwähne in den page_layouts und elements guides, dass bei änderungen der server immer neu gestartet werden muss!

Erstelle einen Link zu dem Rendering Process in Rails http://guides.rubyonrails.org/layouts_and_rendering.html
-- auch innerhalb http://guides.alchemy-cms.com/pages.html

Link auf ( http://guides.alchemy-cms.com/create_elements.html) zu der Dokumentation der Helper-Klassen funktioniert nicht

Link auf( http://guides.alchemy-cms.com/how_to_work_with_alchemy.html) unter 2.1  zu Create_Elements aktualisieren

Falls der User dynamisch Inhalte hinzufügen darf, muss das element vorher definiert werden und kann anschließend in das available_contents: kommplett kopiert werden

Falls Javascript benutzt werde soll, muss innerhalb der application.html.erb ( app/views/layouts) im Body-Tag:
<%= stylesheet_link_tag '<Name der Javasscript-Datei' %> eingetragen werden. Die Javascript-Datei selbst liegt unter app/assets/javascript .
Innerhalb der "Haupt"-Javascript-Datei kann '//= require tree.' verwendet werden um alle Javascriptdateien, die in Unterverzeichnissen liegen mit in die "Haupt"-Javascript-Datei zu laden, außerdem sollte man '//= require jquery' verwenden, weil ich vielen Fällen JQuery benutzt wird


