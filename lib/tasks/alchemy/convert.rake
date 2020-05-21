# frozen_string_literal: true
namespace :alchemy do
  namespace :convert do
    namespace :urlnames do
      desc "Converts the urlname of all pages to nested url paths."
      task to_nested: [:environment] do
        Alchemy::Deprecation.warn('alchemy:convert:urlnames:to_nested task is deprecated and will be removed from Alchemy 5.0')
        unless Alchemy::Config.get(:url_nesting)
          raise "\nURL nesting is disabled! Please enable url_nesting in `config/alchemy/config.yml` first.\n\n"
        end

        puts "Converting..."
        pages = Alchemy::Page.contentpages
        count = pages.count
        pages.each_with_index do |page, n|
          puts "Updating page #{n + 1} of #{count}"
          page.update_urlname!
        end
        puts "Done."
      end

      desc "Converts the urlname of all pages to contain the slug only."
      task to_slug: [:environment] do
        Alchemy::Deprecation.warn('alchemy:convert:urlnames:to_slug task is deprecated and will be removed from Alchemy 5.0')
        if Alchemy::Config.get(:url_nesting)
          raise "\nURL nesting is enabled! Please disable url_nesting in `config/alchemy/config.yml` first.\n\n"
        end

        puts "Converting..."
        pages = Alchemy::Page.contentpages
        count = pages.count
        pages.each_with_index do |page, n|
          puts "Updating page #{n + 1} of #{count}"
          page.update_attribute :urlname, page.slug
        end
        puts "Done."
      end
    end
  end
end
