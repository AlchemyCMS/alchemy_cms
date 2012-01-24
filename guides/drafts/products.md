1. Ein Produkt Element einführen

		# elements.yml
		- name: product
		  contents:
		  - name: product_id
		    type: EssenceProduct # Ein extra Model, welches acts_as_essence hat und per foreign_key auf ein Product referenziert.
		  - name: image
		    type: EssencePicture
		  - name: description
		    type: EssenceRichtext
		  available_contents:
		  - name: audio_sample
		    type: EssenceAudio

	Um beliebig weitere Essenzen ergänzen.

	Ich habe hier die Möglichkeit eingebaut dynamisch hinzufügbare (optionale) Essenzen anzugeben. 
	Dann ist das Formular nicht so riesig und ein Produkt kann um weitere Angaben ergänzt werden. 
	Zum Beispiel, wenn die Audio Samples nur optional sind.
	
	**Diese Funktion ist im `next_stable` branch noch nicht getestet. Es kann da also 1 bis 2 Bugs geben, die wir dann aber schnell beheben können.**

2. Die Produkt Essenz generieren

		rails generate model Alchemy::EssenceProduct

3. Das Model etwas anpassen

		# app/models/alchemy/essence_product.rb
		module Alchemy
		  EssenceProduct < ActiveRecord::Base
		    belongs_to :product
		    acts_as_essence :ingredient_column => :product_id
		  end
		end

4. Die Views erstellen:
	
	View:
	
		# app/views/alchemy/essences/_essence_product_view.html.erb
		<% product = Product.find_by_id(content.ingredient) %>
		<h1><%= product.name %></h1>

	Editor:

		# app/views/alchemy/essences/_essence_product_editor.html.erb
		<%= select_tag content.form_field_name, options_for_select(Product.all.map { |p| [p.name, p.id] }, content.ingredient), :id => content.form_field_id %>
	

5. Die Element Views generieren

		rails g alchemy:elements
