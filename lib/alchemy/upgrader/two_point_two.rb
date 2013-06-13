module Alchemy
  module Upgrader::TwoPointTwo

  private
  
    def convert_essence_texts_displayed_as_select_into_essence_selects
      desc "Converting EssenceTexts displayed as select into EssenceSelects"
      contents_found = 0
      elements = Alchemy::Element.descriptions.select { |e| e['contents'].present? && !e['contents'].detect { |c| c['settings'].present? && c['settings']['display_as'] == 'select' }.nil? }
      contents = elements.collect { |el| el['contents'] }.flatten.select { |c| c['settings'] && c['settings']['display_as'] == 'select' }.flatten
      content_names = contents.collect { |c| c['name'] }
      Alchemy::Content.essence_texts.where(
        :name => content_names,
        :alchemy_elements => {:name => elements.collect { |e| e['name'] }}
      ).joins(:element).each do |content|
        new_content = Alchemy::Content.new(:name => content.name, :element_id => content.element.id)
        if new_content.create_essence!('name' => content.name, 'type' => 'EssenceSelect')
          new_content.essence.value = content.ingredient
          if new_content.essence.save
            contents_found += 1
            log "Converted #{content.name}'s essence_type into EssenceSelect"
            content.destroy
          else
            log "Could not save essence: #{new_content.essence.errors.full_messages.join(', ')}", :error
          end
        else
          log "Could not create content: #{new_content.errors.full_messages.join(', ')}", :error
        end
      end
      if contents_found > 0
        todo "Please open your elements.yml file and change all type values from these contents:\n\n#{content_names.join(', ')}\n\ninto EssenceSelect."
      else
        log "No EssenceTexts with display_as select setting found.", :skip
      end
    end

    def convert_essence_texts_displayed_as_checkbox_into_essence_booleans
      desc "Converting EssenceTexts displayed as checkbox into EssenceBooleans"
      contents_found = 0
      elements = Alchemy::Element.descriptions.select { |e| e['contents'].present? && !e['contents'].detect { |c| c['settings'].present? && c['settings']['display_as'] == 'checkbox' }.nil? }
      contents = elements.collect { |el| el['contents'] }.flatten.select { |c| c['settings'] && c['settings']['display_as'] == 'checkbox' }.flatten
      content_names = contents.collect { |c| c['name'] }
      Alchemy::Content.essence_texts.where(
        :name => content_names,
        :alchemy_elements => {:name => elements.collect { |e| e['name'] }}
      ).joins(:element).each do |content|
        new_content = Alchemy::Content.new(:name => content.name, :element_id => content.element.id)
        if new_content.create_essence!('name' => content.name, 'type' => 'EssenceBoolean')
          new_content.essence.value = content.ingredient
          if new_content.essence.save
            contents_found += 1
            log "Converted #{content.name}'s essence_type into EssenceBoolean"
            content.destroy
          else
            log "Could not save essence: #{new_content.essence.errors.full_messages.join(', ')}", :error
          end
        else
          log "Could not create content: #{new_content.errors.full_messages.join(', ')}", :error
        end
      end
      if contents_found > 0
        todo "Please open your elements.yml file and change all type values from these contents:\n\n#{content_names.join(', ')}\n\ninto EssenceBoolean."
      else
        log "No EssenceTexts with display_as checkbox setting found.", :skip
      end
    end

  end
end
