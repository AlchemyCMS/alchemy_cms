Erstellen von Alchemy Modulen
=============================

Hinweis: Dieser Guide bezieht sich auf [Alchemy 2.1](https://github.com/magiclabs/alchemy_cms/tree/next_stable) und für den Einsatz in einer Rails 3.1 Applikation.

Ein Alchemy Modul ist nichts anderes als eine Rails Engine. Dazu gibt es ja auch viel Infos im Netz zu.

Es gibt verschiedene Arten um ein Alchemy Modul zu erstellen.

Entweder hat die Main App ein paar Controller, die man nur für das Projekt benötigt.
Oder man erstellt eine Engine welche als Gem wiederverwendbar in andere Projekte einsetzbar ist.

So wie das [Alchemy CRM Modul](https://github.com/magiclabs/alchemy_crm/tree/rails31)


Einbindung in Alchemy
---------------------

Grundsätzlich ist die Vorgehensweise bei beiden Vorgehensweisen gleich.

Die Einbindung in Alchemy läuft über Rails Initializer.

In der Main App liegen die unter `config/initializers`.

Im Gem sollte man die `initializer` Methode von `Rails::Engine` benutzen.

Siehe [Alchemy CRM](https://github.com/magiclabs/alchemy_crm/tree/rails31/lib/alchemy_crm/engine.rb)


In den Routen Mounten
---------------------

Alchemy kann als Mountable Engine an jeden beliebigen mount point der Routen eingebunden werden.

In einer "Alchemy only"-App würde man Alchemy unter `/` mounten:

	# config/routes.rb
	ChristianBischoffLive::Application.routes.draw do
		...
		mount Alchemy::Engine => '/'
	end

Man kann Alchemy aber auch zB unter `cms` mounten, oder `typo3` :)

Tip: Da Alchemy sehr starke Routen hat, sollte man die eigenen Routen immer vor Alchemy deklarieren.


Alchemy als Admin Backend nutzen
--------------------------------

Damit die eigenen Admin Controller in der Navigation des Alchemy Backends erscheinen sollte man sie einfach mittels `Alchemy::Modules.register_module` hinzufügen. Als Argument übergibt man einen Hash.
Den man z.B. auch als YAML Datei anlegen könnte und per `YAML.load_file` an die Methode übergeben könnte.

Siehe auch [Alchemy CRM](https://github.com/magiclabs/alchemy_crm/tree/rails31/config/module_definition.yml)

Initializer Beispiel:

	# config/initializers/alchemy_modules.rb
	Alchemy::Modules.register_module({
		:name => 'parms',
		:navigation => {
			:name => 'Kinderwagen',
			:controller => '/admin/parms',
			:action => 'index',
			:sub_navigation => [
				{
					:name => 'Kinderwagen',
					:controller => '/admin/parms',
					:action => 'index'
				},
				{
					:name => 'Bewertungen',
					:controller => '/admin/reviews',
					:action => 'index'
				},
				{
					:name => 'Feedback',
					:controller => '/admin/feedbacks',
					:action => 'index'
				}
			]
		}
	})

Weitere Beispiele der Parameter: siehe -> [Alchemy CMS](https://github.com/magiclabs/alchemy_cms/tree/next_stable/config/alchemy/modules.yml)

Man kann so jedem Modul sein eigenes Set an Controllern zuweisen und in der Subnavi erscheinen lassen.
Meistens macht man in einer kleinen App alle Controller in ein Modul. Man könnte sie aber auch Kontext bezogen zusammen fassen.


Alchemy Resources Controller:
-----------------------------

Alchemy ist prima als CRUD Admin Backend einsetzbar.

Man braucht die eigenen Admin Controller nur vom `Alchemy::Admin::ResourcesController` erben lassen.

Beispiel:

	# encoding: UTF-8
	module Admin
		class FeedbacksController < Alchemy::Admin::ResourcesController
		end
	end

Mehr ist nicht nötig ;) Alchemy erstellt alle 7 CRUD Methoden und schützt den Controller vor unauthorisierten Zugriff.

Dadurch hat man alles was man auch sonst so aus dem Alchemy Backend kennt:

- Eine Tableview der Einträge inkl. Pagination
- eine Volltext Suche über alle String Attribute der Einträge
- Einen Create Button
- Edit und Destroy Buttons pro Eintrag

Sollten die Views nicht ausreichen kann man sie einfach überschreiben. Man hat in den Views Instanz Variablen benannt nach der Resource zur Verfügung (`@feedbacks` für eine `Feedback` Resource, etc.)

Die einzelnen Actions des Controllers kann man natürlich auch überschreiben und so an die eigenen Bedürfnisse anpassen.


Authentifizierung
-----------------

Damit die Admin User die eigenen Admin Controller auch aufrufen dürfen müssen die Rechte angepasst werden.

Die Rechte zu den jeweiligen Rollen sind in einer `config/authorization_rules.rb` Datei einstellbar:

	# config/authorization_rules.rb
	authorization do

	  role :customer do
	    has_permission_on :registrations, :to => [:manage] do
	      if_attribute :id => is {user.id}
	    end
	  end

	  role :admin do
	    has_permission_on :admin_registrations, :to => [:manage]
	  end

	end

Weitere Infos zur DSL unter -> [https://github.com/stffn/declarative_authorization](https://github.com/stffn/declarative_authorization)

Ist das Modul ein Gem, dann muss man die Regeln Alchemy noch mittels `initializer` mitteilen:

	# lib/alchemy_products_module/engine.rb
	  ...
	  initializer "alchemy_crm.add_authorization_rules" do
	    Alchemy::AuthEngine.get_instance.load(File.join(File.dirname(__FILE__), '../..', 'config/authorization_rules.rb'))
	  end
	  ...

Siehe auch hierzu im [Alchemy CRM Modul](https://github.com/magiclabs/alchemy_crm/tree/rails31/lib/alchemy_crm/engine.rb)


Eigene Benutzerollen
--------------------

Zusätzliche Benutzerrollen können ganz einfach mittels der Alchemy Konfiguration hinzugefügt werden:

	# config/alchemy/config.yml
	user_roles: [customer, registered, author, editor, admin]

Dann nur noch die Regeln anpassen.
