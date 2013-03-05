require 'fileutils'
require 'active_record'

module Alchemy
  class Upgrader < Alchemy::Seeder

    class << self

      # Runs ugrades
      #
      # Set UPGRADE env variable to only run a specific task.
      def run!
        if ENV['UPGRADE']
          ENV['UPGRADE'].split(',').each do |task|
            self.send(task)
          end
        else
          run_all
        end
        display_todos
      end

      def run_all
        Rake::Task['alchemy:install:migrations'].invoke
        strip_alchemy_from_schema_version_table
        Rake::Task['db:migrate'].invoke
        Seeder.seed!
        upgrade_to_language
        upgrade_layoutpages
        upgrade_essence_link
        upgrade_to_namespaced_essence_type
        convert_essence_texts_to_essence_selects
        convert_essence_texts_to_essence_booleans
        copy_new_config_file
        gallery_pictures_change_notice
        removed_richmedia_essences_notice
        convert_picture_storage
        removed_standard_set_notice
        renamed_t_method
        migrated_to_devise
      end

      def list_tasks
        puts "\nAvailable upgrade tasks"
        puts "-----------------------\n"
        (self.private_methods - Object.private_methods - superclass.private_methods).each do |method|
          puts method
        end
        puts "\nUsage:"
        puts "------"
        puts "Run one or more tasks with `bundle exec rake alchemy:upgrade UPGRADE=task_name1,task_name2`\n"
      end

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

      def upgrade_essence_link
        desc "Setting new link_target default"
        essences = (Alchemy::EssencePicture.all + Alchemy::EssenceText.all)
        if essences.any?
          essences.each do |essence|
            case essence.link_target
            when '1'
              if essence.update_column(:link_target, 'blank')
                log("Updated #{essence.preview_text} link target to #{essence.link_target}.")
              end
            when '0'
              essence.update_column(:link_target, nil)
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
            if c.update_column(:essence_type, c.essence_type.gsub(/^Essence/, 'Alchemy::Essence'))
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

      def strip_alchemy_from_schema_version_table
        desc "Strip -alchemy suffix from schema_version table."
        database_yml = YAML.load_file(Rails.root.join("config", "database.yml"))
        adapter = ActiveRecord::Base.establish_connection(database_yml.fetch(Rails.env.to_s).symbolize_keys)
        adapter.connection.update("UPDATE schema_migrations SET version = REPLACE(`schema_migrations`.`version`,'-alchemy','')")
      end

      def convert_essence_texts_to_essence_selects
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

      def convert_essence_texts_to_essence_booleans
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

      def copy_new_config_file
        desc "Copy configuration file."
        config_file = Rails.root.join('config/alchemy/config.yml')
        default_config = File.join(File.dirname(__FILE__), '../../config/alchemy/config.yml')
        if FileUtils.identical? default_config, config_file
          log "Configuration file already present.", :skip
        else
          log "Custom configuration file found."
          FileUtils.cp default_config, Rails.root.join('config/alchemy/config.yml.defaults')
          log "Copied new default configuration file."
          todo "Check the default configuration file (./config/alchemy/config.yml.defaults) for new configuration options and insert them into your config file."
        end
      end

      def gallery_pictures_change_notice
        txt = ["We have changed the way Alchemy handles EssencePictures in elements."]
        txt << "It is now possible to have single EssencePictures and galleries side by side in the same element."
        txt << "All element editor views containing render_picture_editor with option `maximum_amount_of_images => 1` must be changed into render_essence_editor_by_name."
        txt << "In the yml description of these elements add a new content for this picture."
        txt << "\nIn order to upgrade your elements in the database run:"
        txt << "\nrails g alchemy:gallery_pictures_migration\n"
        txt << "and alter `db/seeds.rb`, so that it contains all elements that have essence pictures."
        todo txt.join("\n")
      end

      def removed_richmedia_essences_notice
        warn = <<-WARN
We removed the EssenceAudio, EssenceFlash and EssenceVideo essences from Alchemy core!
In order to get the essences back, install the `alchemy-richmedia-essences` gem.

gem 'alchemy-richmedia-essences'

We left the tables in your database, you can simply drop them if you don't use these essences in your project.

drop_table :alchemy_essence_audios
drop_table :alchemy_essence_flashes
drop_table :alchemy_essence_videos
WARN
        todo warn
      end

      def convert_picture_storage
        desc "Convert the picture storage"
        images = Dir.glob Rails.root.join 'uploads/pictures/**/*.*'
        if images.blank?
          log "No pictures found", :skip
        else
          images.each do |image|
            image_uid = image.gsub(/#{Rails.root.to_s}\/uploads\/pictures\//, '')
            image_id = image_uid.split('/').last.split('.').first
            picture = Alchemy::Picture.find_by_id(image_id)
            if picture && picture.image_file_uid.blank?
              picture.image_file_uid = image_uid
              picture.image_file_size = File.new(image).size
              if picture.save!
                log "Converted #{image_uid}"
              end
            else
              log "Picture with id #{image_id} not found or already converted.", :skip
            end
          end
        end
      end

      def convert_attachment_storage
        desc "Convert the attachment storage"
        attachments = Dir.glob Rails.root.join 'uploads/attachments/**/*.*'
        if attachments.blank?
          log "No attachments found", :skip
        else
          attachments.each do |attachment|
            file_uid = attachment.gsub(/#{Rails.root.to_s}\/uploads\/attachments\//, '')
            url_parts = file_uid.split('/')
            file_id = url_parts[url_parts.length-2].to_i
            attachment = Alchemy::Attachment.find_by_id(file_id)
            if attachment && attachment.file_uid.blank?
              attachment.file_uid = file_uid
              if attachment.save!
                log "Converted #{file_uid}"
              end
            else
              log "Attachment with id #{file_id} not found or already converted.", :skip
            end
          end
        end
      end

      def removed_standard_set_notice
        warn = <<-WARN
We removed the standard set from Alchemy core!
In order to get the standard set back, install the `alchemy-demo_kit` gem.
WARN
        todo warn
      end

      def renamed_t_method
        warn = <<-WARN
We renamed alchemy's `t` method override into `_t` to avoid conflicts with Rails own t method!
If you use the `t` method to translate alchemy scoped keys, then you have to use the `_t` method from now on.
WARN
        todo warn
      end

      def migrated_to_devise
        warn = <<-WARN
We changed the authentication provider from Authlogic to Devise.

If you are upgrading from an old Alchemy version < 2.5.0, then you have to make changes to your Devise configuration.

  1. Run:

  $ rails g alchemy:devise

  And alter the encryptor to authlogic_sha512
  and the stretches value from 10 to 20

  # config/initializers/devise.rb
  config.stretches = Rails.env.test? ? 1 : 20
  config.encryptor = :authlogic_sha512

  2. Add the encryptable module to your Alchemy config.yml:

  # config/alchemy/config.yml
  devise_modules:
    - :database_authenticatable
    - :trackable
    - :validatable
    - :timeoutable
    - :recoverable
    - :encryptable

WARN
        todo warn
      end

    end

  end
end
