module Alchemy
  class Upgrader::FourPointZero < Upgrader
    class << self
      def create_page_versions
        desc "Create versions for pages"
        Alchemy::Page.find_each do |page|
          next if page.systempage? || page.redirects_to_external?
          page.build_current_version(page_id: page.id)
          log "Created version for Page #{page.urlname}"
          if page.public?
            page.public_version = page.versions.last
            log "Created public version for Page #{page.urlname}"
          end
          page.save!
        end
      end
    end
  end
end
