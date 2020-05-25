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

    namespace :page_trees do
      desc "Converts the page tree into a menu."
      task to_menus: [:environment] do
        if Alchemy::Node.roots.exists?
          abort "\n⨯ There are already menus present in your database. Aborting!"
        end

        def name_for_node(page)
          if page.visible? && page.public? && !page.definition['redirects_to_external']
            nil
          else
            page.name
          end
        end

        def page_for_node(page)
          if page.visible? && page.public? && !page.definition['redirects_to_external']
            page
          elsif Alchemy::Config.get(:redirect_to_public_child) && page.visible? && !page.public? && page.children.published.any?
            page.children.published.first
          end
        end

        def convert_to_nodes(children, node:)
          children.each do |page|
            has_children = page.children.any?
            next unless page.visible || has_children

            Alchemy::Deprecation.silence do
              new_node = node.children.create!(
                name: name_for_node(page),
                page: page_for_node(page),
                url: page.definition['redirects_to_external'] ? page.urlname : nil,
                external: page.definition['redirects_to_external'] && Alchemy::Config.get(:open_external_links_in_new_tab),
                language_id: page.language_id
              )
              print "."
              if has_children
                convert_to_nodes(page.children, node: new_node)
              end
            end
          end
        end

        menu_count = Alchemy::Language.count
        puts "\n- Converting #{menu_count} page #{'tree'.pluralize(menu_count)} into #{'menu'.pluralize(menu_count)}."
        Alchemy::BaseRecord.transaction do
          Alchemy::Language.all.each do |language|
            locale = language.locale.presence || I18n.default_locale
            menu_name = I18n.t('Main Navigation', scope: 'alchemy.menu_names', default: 'Main Navigation', locale: locale)
            root_node = Alchemy::Node.create(language: language, name: menu_name)
            language.pages.language_roots.each do |root_page|
              convert_to_nodes(root_page.children, node: root_node)
            end
          end
        end
        puts "\n✓ Done."
      end
    end
  end
end
