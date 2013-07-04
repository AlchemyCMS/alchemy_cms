module Alchemy
  module Upgrader::TwoPointOne

  private

    # Creates Language model if it does not exist (Alchemy CMS prior v1.5)
    # Also creates missing associations between pages and languages
    def upgrade_to_language
      desc "Creating languages for pages"
      Alchemy::Page.all.each do |page|
        if !page.language_code.blank? && page.language.nil?
          root = page.get_language_root
          lang = Alchemy::Language.find_or_create_by_language_code(
            :name => page.language_code.capitalize,
            :language_code => page.language_code,
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
      raise "No default language found." if default_language.nil?
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
          if c.update_attribute(:essence_type, c.essence_type.gsub(/\AEssence/, 'Alchemy::Essence'))
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
    end

  end
end
