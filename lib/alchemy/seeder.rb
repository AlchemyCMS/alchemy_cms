require "alchemy/shell"

module Alchemy
  class Seeder
    extend Alchemy::Shell

    class << self
      # This seed builds the necessary page structure for Alchemy in your database.
      #
      # Call this from your +db/seeds.rb+ file with the `rake db:seed task'.
      #
      def seed!
        create_default_site
        if create_root_page
          try_seed_pages
        elsif page_seeds_file.file?
          desc "Seeding Alchemy pages"
          log "There are already pages present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
        end
        seed_users if user_seeds_file.file?
      end

      protected

      def create_default_site
        desc "Creating default Alchemy site"
        if Alchemy::Site.count == 0
          site = Alchemy::Site.new(
            name: site_config['name'],
            host: site_config['host']
          )
          if Alchemy::Language.any?
            site.languages = Alchemy::Language.all
          end
          site.save!
          log "Created default Alchemy site with default language."
        else
          log "Default Alchemy site was already present.", :skip
        end
      end

      def create_root_page
        desc "Creating Alchemy root page"
        root = Alchemy::Page.find_or_initialize_by(name: 'Root')
        root.do_not_sweep = true
        if root.new_record?
          if root.save!
            log "Created Alchemy root page."
            return true
          end
        else
          log "Alchemy root page was already present.", :skip
          return false
        end
      end

      def try_seed_pages
        if page_seeds_file.file?
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
            parent: Alchemy::Page.root,
            language: Alchemy::Language.default,
            language_root: true
          })
        end
      end

      def seed_layoutpages
        desc "Seeding Alchemy layout pages from #{page_seeds_file}"
        language = Alchemy::Language.default
        layout_root = Alchemy::Page.find_or_create_layout_root_for(language.id)
        layoutpages.each do |page|
          create_page(page, {
            parent: layout_root,
            language: language
          })
        end
      end

      def seed_users
        desc "Seeding Alchemy users from #{user_seeds_file}"

        if Alchemy.user_class.exists?
          log "There are already users present in your database. " \
              "Please use `rake db:reset' if you want to rebuild your database.", :skip
          return false
        else
          users = YAML.load_file(user_seeds_file)
          users.each do |draft|
            user = Alchemy.user_class.create!(draft)
            log "Created user: #{user.try(:email) || user.try(:login) || user.id}"
          end
        end
      end

      private

      def site_config
        @_site_config ||= Alchemy::Config.get(:default_site)
      end

      def page_seeds_file
        @_page_seeds_file ||= Rails.root.join('db', 'seeds', 'alchemy', 'pages.yml')
      end

      def page_yml
        @_page_yml ||= YAML.load_file(page_seeds_file)
      end

      def contentpages
        page_yml.select { |p| !p['layoutpage'] }
      end

      def layoutpages
        page_yml.select { |p| p['layoutpage'] }
      end

      def user_seeds_file
        @_user_seeds_file ||= Rails.root.join('db', 'seeds', 'alchemy', 'users.yml')
      end

      def create_page(draft, attributes = {})
        children = draft.delete('children') || []
        page = Alchemy::Page.create!(draft.merge(attributes))
        log "Created page: #{page.name}"
        children.each do |child|
          create_page(child, parent: page)
        end
      end
    end
  end
end
