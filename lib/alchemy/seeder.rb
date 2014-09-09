require "alchemy/shell"

module Alchemy
  class Seeder
    extend Alchemy::Shell

    class << self

      # Builds necessary objects in your database, like default site, node and language.
      #
      # Call this from your db/seeds.rb file with the rake db:seed task.
      #
      def seed!
        create_default_site
        create_default_node
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

      def create_default_node
        desc "Creating default Alchemy node"
        if Alchemy::Node.count == 0
          node = Alchemy::Node.new(
            name: Alchemy::I18n.t('Main navigation')
          )
          node.save!
          log "Created default Alchemy node."
        else
          log "Default Alchemy node was already present.", :skip
        end
      end
    end
  end
end
