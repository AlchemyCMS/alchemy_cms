module Alchemy
	class Content < ActiveRecord::Base

		belongs_to :essence, :polymorphic => true, :dependent => :destroy
		belongs_to :element

		stampable :stamper_class_name => :user

		acts_as_list

		def scope_condition
			"element_id = '#{element_id}' AND essence_type = '#{essence_type}'"
		end

		validates_uniqueness_of :name, :scope => :element_id
		validates_uniqueness_of :position, :scope => [:element_id, :essence_type]

		scope :essence_pictures, where(:essence_type => "Alchemy::EssencePicture")
		scope :essence_texts, where(:essence_type => "Alchemy::EssenceText")
		scope :essence_richtexts, where(:essence_type => "Alchemy::EssenceRichtext")

		# Creates a new Content as descriped in the elements.yml file
		def self.create_from_scratch(element, essences_hash)
			if essences_hash[:name].blank? && !essences_hash[:essence_type].blank?
				essences_of_same_type = element.contents.where(
					:essence_type => Alchemy::Content.normalize_essence_type(essences_hash[:essence_type])
				)
				description = {
					'type' => essences_hash[:essence_type],
					'name' => "#{essences_hash[:essence_type].classify.demodulize.underscore}_#{essences_of_same_type.count + 1}"
				}
			else
				description = element.content_description_for(essences_hash[:name])
				description = element.available_content_description_for(essences_hash[:name]) if description.blank?
			end
			raise "No description found in elements.yml for #{essences_hash.inspect} and #{element.inspect}" if description.blank?
			essence_class = Alchemy::Content.normalize_essence_type(description['type']).constantize
			content = self.new(:name => description['name'], :element_id => element.id)
			if description['type'] == "EssenceRichtext" || description['type'] == "EssenceText"
				essence = essence_class.create(:do_not_index => !description['do_not_index'].nil?)
			else
				essence = essence_class.create
			end
			if essence
				content.essence = essence
				content.save
			else
				content = nil
			end
			return content
		end

		# Settings from the elements.yml definition
		def settings
			return {} if description.blank?
			settings = description['settings']
			return {} if settings.blank?
			settings.symbolize_keys
		end

		def siblings
			return [] if !element
			self.element.contents
		end

		# makes a copy of source and copies the polymorphic associated essence
		def self.copy(source, differences = {})
			differences[:position] = nil
			differences[:id] = nil
			attributes = source.attributes.merge(differences)
			content = self.create!(attributes.except("id"))
			new_essence = content.essence.clone
			new_essence.save
			content.essence_id = new_essence.id
			content
		end

		# Returns my description hash from elements.yml
		# Returns the description from available_contents if my own description is blank
		def description
			if self.element.blank?
				logger.warn("\n+++++++++++ Warning: Content with id #{self.id} is missing its Element\n")
				return nil
			else
				desc = self.element.content_description_for(self.name)
				if desc.blank?
					desc = self.element.available_content_description_for(self.name)
				else
					return desc
				end
			end
		end

		# Gets the ingredient from essence
		def ingredient
			return nil if self.essence.nil?
			self.essence.ingredient
		end

		# Calls essence.update_attributes. Called from +Alchemy::Element#save_contents+
		# Ads errors to self.base if essence validation fails.
		def update_essence(params={})
			raise "Essence not found" if essence.nil?
			if essence.update_attributes(params)
				return true
			else
				errors.add(:essence, :validation_failed)
				return false
			end
		end

		def essence_validation_failed?
			essence.errors.any?
		end

		def has_validations?
			return false if description.blank?
			!description['validate'].blank?
		end

		# Returns a string to be passed to Rails form field tags to ensure we have same params layout everywhere.
		# 
		# === Example:
		# 
		#   <%= text_field_tag content.form_field_name, content.ingredient %>
		# 
		# === Options:
		# 
		# You can pass an Essence column_name. Default is self.essence.ingredient_column
		# 
		# ==== Example:
		# 
		#   <%= text_field_tag content.form_field_name(:link), content.ingredient %>
		# 
		def form_field_name(essence_column = self.essence.ingredient_column)
			"contents[content_#{self.id}][#{essence_column}]"
		end

		def form_field_id(essence_column = self.essence.ingredient_column)
			"contents_content_#{self.id}_#{essence_column}"
		end

		# Returns the translated name for displaying in labels, etc.
		def name_for_label
			self.class.translated_label_for(self.name, self.element.name)
		end

		# Returns the translated label for a content name.
		# 
		# Translate it in your locale yml file:
		# 
		#   alchemy:
		#     content_names:
		#      foo: Bar
		# 
		# Optionally you can scope your content name to an element:
		# 
		#   alchemy:
		#     content_names:
		#      article:
		#       foo: Baz
		# 
		def self.translated_label_for(content_name, element_name = nil)
			Alchemy::I18n.t("content_names.#{element_name}.#{content_name}", :default => ["content_names.#{content_name}".to_sym, content_name.capitalize])
		end

		def linked?
			essence && !essence.link.blank?
		end

		def essence_partial_name
			essence.partial_name
		end

		def normalized_essence_type
			self.class.normalize_essence_type(self.essence_type)
		end

		def self.normalize_essence_type(essence_type)
			essence_type = essence_type.classify
			if not essence_type.match(/^Alchemy::/)
				essence_type.gsub!(/^Essence/, 'Alchemy::Essence')
			else
				essence_type
			end
		end

	end
end
