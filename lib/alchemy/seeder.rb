require "alchemy/shell"

module Alchemy
  class Seeder
    extend Alchemy::Shell

    class << self

      # This seed builds the necessary page structure for alchemy in your database.
      # Run the alchemy:db:seed rake task to seed your database.
      def seed!
        create_default_site
        create_root_page
      end

    protected

      def create_default_site
        desc "Creating default Alchemy site"
        if Alchemy::Site.count == 0
          site = Alchemy::Site.new(
            name: 'Default Site',
            host: '*'
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

    end

  end
end
