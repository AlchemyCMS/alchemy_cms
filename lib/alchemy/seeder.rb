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
        create_root_page
        seed_pages if page_seeds_file.file?
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
          end
        else
          log "Alchemy root page was already present.", :skip
        end
      end

      def seed_pages
        desc "Seeding Alchemy pages from #{page_seeds_file}"
        pages = YAML.load_file(page_seeds_file)
        if pages.length > 1
          abort "The pages seed file must only contain one root page! You have #{pages.length}."
        end
        pages.each do |page|
          create_page(page, {
            parent: Alchemy::Page.root,
            language: Alchemy::Language.default,
            language_root: true
          })
        end
      end

      private

      def site_config
        @_site_config ||= Alchemy::Config.get(:default_site)
      end

      def page_seeds_file
        @_page_seeds_file ||= Rails.root.join('db', 'seeds', 'alchemy', 'pages.yml')
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
