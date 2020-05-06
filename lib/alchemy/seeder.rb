# frozen_string_literal: true
require "alchemy/shell"

module Alchemy
  # This seeder builds Alchemy pages in your database.
  #
  # Create a +db/seeds/alchemy/pages.yml+ and +db/seeds/alchemy/users.yml+ files
  # and put +Alchemy::Seeder.seed!+ into your +db/seeds.rb+ file.
  #
  # Then run +rake db:seed+
  #
  class Seeder
    extend Alchemy::Shell

    class << self
      # Put +Alchemy::Seeder.seed!+ into your +db/seeds.rb+ file and run +rake db:seed+.
      #
      def seed!
        try_seed_pages
        seed_users if user_seeds_file.file?
      end

      protected

      def try_seed_pages
        return unless page_seeds_file.file?

        if Alchemy::Page.exists?
          desc "Seeding Alchemy pages"
          log "There are already pages present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
        else
          create_default_site! unless Alchemy::Site.default
          create_default_language! unless Alchemy::Language.default
          seed_pages if contentpages.present?
          seed_layoutpages if layoutpages.present?
        end
      end

      def seed_pages
        desc "Seeding Alchemy content pages from #{page_seeds_file}"
        if contentpages.length > 1
          abort "The pages seed file must only contain one root page! You have #{contentpages.length}."
        end

        contentpages.each do |page|
          create_page(page, {
            language: Alchemy::Language.default,
            language_root: true,
          })
        end
      end

      def seed_layoutpages
        desc "Seeding Alchemy layout pages from #{page_seeds_file}"
        language = Alchemy::Language.default
        layoutpages.each do |page|
          create_page(page, { language: language })
        end
      end

      def seed_users
        desc "Seeding Alchemy users from #{user_seeds_file}"

        if Alchemy.user_class.exists?
          log "There are already users present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
          false
        else
          users = YAML.load_file(user_seeds_file)
          users.each do |draft|
            user = Alchemy.user_class.create!(draft)
            log "Created user: #{user.try(:email) || user.try(:login) || user.id}"
          end
        end
      end

      private

      def page_seeds_file
        @_page_seeds_file ||= Rails.root.join("db", "seeds", "alchemy", "pages.yml")
      end

      def page_yml
        @_page_yml ||= YAML.load_file(page_seeds_file)
      end

      def contentpages
        page_yml.reject { |p| p["layoutpage"] }
      end

      def layoutpages
        page_yml.select { |p| p["layoutpage"] }
      end

      def user_seeds_file
        @_user_seeds_file ||= Rails.root.join("db", "seeds", "alchemy", "users.yml")
      end

      def create_page(draft, attributes = {})
        children = draft.delete("children") || []
        page = Alchemy::Page.create!(draft.merge(attributes))
        log "Created page: #{page.name}"
        children.each do |child|
          create_page(child, parent: page, language: page.language)
        end
      end

      # If no languages are present, create a default language based
      # on the host app's Alchemy configuration.
      def create_default_language!
        default_language = Alchemy::Config.get(:default_language)
        if default_language
          Alchemy::Language.create!(
            name: default_language["name"],
            language_code: default_language["code"],
            locale: default_language["code"],
            frontpage_name: default_language["frontpage_name"],
            page_layout: default_language["page_layout"],
            public: true,
            default: true,
            site: Alchemy::Site.default,
          )
        else
          raise DefaultLanguageNotFoundError
        end
      end

      def create_default_site!
        default_site = Alchemy::Config.get(:default_site)
        if default_site
          Alchemy::Site.create!(name: default_site["name"], host: default_site["host"])
        else
          raise DefaultSiteNotFoundError
        end
      end
    end
  end
end
