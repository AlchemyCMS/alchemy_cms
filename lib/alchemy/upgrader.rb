module Alchemy
  class Upgrader < Alchemy::Seeder

    class << self

      # Runs all ugrades
      def run!
        Rake::Task['alchemy:install:migrations'].invoke
        strip_alchemy_from_schema_version_table
        Rake::Task['db:migrate'].invoke
        upgrade_to_language
        upgrade_layoutpages
        upgrade_essence_link_target_default
        upgrade_to_namespaced_essence_type
        convert_essence_texts_displayed_as_select_into_essence_selects
        display_todos
      end

    private

      # Creates Language model if it does not exist (Alchemy CMS prior v1.5)
      # Also creates missing associations between pages and languages
      def upgrade_to_language
        desc "Creating languages for pages"
        Alchemy::Page.all.each do |page|
          if !page.language_code.blank? && page.language.nil?
            root = page.get_language_root
            lang = Alchemy::Language.find_or_create_by_code(
              :name => page.language_code.capitalize,
              :code => page.language_code,
              :frontpage_name => root.name,
              :page_layout => root.page_layout,
              :public => true
            )
            page.language = lang
            if page.save(:validate => false)
              log "Set language for page #{page.name} to #{lang.name}."
            end
          else
            log("Language for page #{page.name} already set.", :skip)
          end
        end
      end

      def upgrade_layoutpages
        desc "Setting language of layoutpages"
        default_language = Alchemy::Language.get_default
        layoutpages = Alchemy::Page.layoutpages
        if layoutpages.any?
          layoutpages.each do |page|
            if page.language.class == String || page.language.nil?
              page.language = default_language
              if page.save(:validate => false)
                log "Set language for page #{page.name} to #{default_language.name}."
              end
            else
              log "Language for page #{page.name} already set.", :skip
            end
          end
        else
          log "No layoutpages found.", :skip
        end
      end

      def upgrade_essence_link_target_default
        desc "Setting new link_target default"
        essences = (Alchemy::EssencePicture.all + Alchemy::EssenceText.all)
        if essences.any?
          essences.each do |essence|
            case essence.link_target
            when '1'
              if essence.update_attribute(:link_target, 'blank')
                log("Updated #{essence.preview_text} link target to #{essence.link_target}.")
              end
            when '0'
              essence.update_attribute(:link_target, nil)
              log("Updated #{essence.preview_text} link target to #{essence.link_target.inspect}.")
            else
              log("#{essence.preview_text} already upgraded.", :skip)
            end
          end
        else
          log("No essences to upgrade found.", :skip)
        end
      end

      # Updates all essence_type of Content if not already namespaced.
      def upgrade_to_namespaced_essence_type
        desc "Namespacing essence_type columns"
        depricated_contents = Alchemy::Content.where("essence_type LIKE ?", "Essence%")
        if depricated_contents.any?
          success = 0
          errors = []
          depricated_contents.each do |c|
            if c.update_attribute(:essence_type, c.essence_type.gsub(/^Essence/, 'Alchemy::Essence'))
              success += 1
            else
              errors << c.errors.full_messages
            end
          end
          log("Namespaced #{success} essence_type columns.") if success > 0
          log("#{errors.count} errors while namespacing essence_type columns.\n#{errors.join('\n')}", :error) if errors.count > 0
        else
          log "No essence_type columns to be namespaced found.", :skip
        end
        todo "Test mich nicht"
      end

      def strip_alchemy_from_schema_version_table
        desc "Strip -alchemy suffix from schema_version table."
        database_yml = YAML.load_file(Rails.root.join("config", "database.yml"))
        connection = Mysql2::Client.new(database_yml.fetch(Rails.env.to_s).symbolize_keys)
        connection.query "UPDATE schema_migrations SET `schema_migrations`.`version` = REPLACE(`schema_migrations`.`version`,'-alchemy','')"
        todo "Teste mich"
      end

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

    end

  end
end
