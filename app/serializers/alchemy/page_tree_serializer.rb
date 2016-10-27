module Alchemy
  class PageTreeSerializer < BaseSerializer
    def attributes
      {'pages' => nil}
    end

    def pages
      tree = []
      path = [{id: object.parent_id, children: tree}]
      page_list = object.self_and_descendants
      skip_branch = false
      base_level = object.level - 1

      page_list.each_with_index do |page, i|
        has_children = page_list[i + 1] && page_list[i + 1].parent_id == page.id
        folded = has_children && page.folded?(opts[:user])

        if skip_branch
          next if page.parent_id == path.last[:children].last[:id]

          skip_branch = false
        end

        # Do not walk my children if I'm folded and you don't need to have the
        # full tree.
        if folded && !opts[:full]
          skip_branch = true
        end

        if page.parent_id != path.last[:id]
          if path.map { |o| o[:id] }.include?(page.parent_id) # Lower level
            path.pop while path.last[:id] != page.parent_id
          else # One level up
            path << path.last[:children].last
          end
        end

        level = path.count + base_level

        path.last[:children] << page_hash(page, has_children, level, folded)
      end

      tree
    end

    protected

    def page_hash(page, has_children, level, folded)
      p_hash = {
        id: page.id,
        name: page.name,
        public: page.public?,
        visible: page.visible?,
        restricted: page.restricted?,
        page_layout: page.page_layout,
        slug: page.slug,
        redirects_to_external: page.redirects_to_external?,
        urlname: page.urlname,
        external_urlname: page.redirects_to_external? ? page.external_urlname : nil,
        level: level,
        root: level == 1,
        root_or_leaf: level == 1 || !has_children,
        children: []
      }

      if opts[:elements]
        p_hash.update(elements: ActiveModel::ArraySerializer.new(page_elements(page)))
      end

      if opts[:ability].can?(:index, :alchemy_admin_pages)
        p_hash.merge({
          definition_missing: page.definition.blank?,
          folded: folded,
          locked: page.locked?,
          locked_notice: page.locked? ? Alchemy.t('This page is locked', name: page.locker_name) : nil,
          status_titles: page_status_titles(page),
          links: page_links(page)
        })
      else
        p_hash
      end
    end

    def page_elements(page)
      if opts[:elements] == 'true'
        page.elements
      else
        page.elements.named(opts[:elements].split(',') || [])
      end
    end

    def page_status_titles(page)
      {
        public: page.status_title(:public),
        visible: page.status_title(:visible),
        restricted: page.status_title(:restricted)
      }
    end

    def routes
      Alchemy::Engine.routes.url_helpers
    end

    def page_links(page)
      [
        {
          label: Alchemy.t(:page_infos),
          label_position: 'center',
          permitted: opts[:ability].can?(:info, page),
          template_name: 'linkToDialog',
          template_locals: {
            icon: 'info',
            url: routes.info_admin_page_path(page),
            options: {
              title: Alchemy.t(:page_infos),
              size: '520x290'
            }
          }
        },
        {
          label: Alchemy.t(:edit_page_properties),
          label_position: 'center',
          permitted: opts[:ability].can?(:configure, page),
          template_name: 'linkToDialog',
          template_locals: {
            icon: 'configure_page',
            url: routes.configure_admin_page_path(page),
            options: {
              title: Alchemy.t(:edit_page_properties),
              size: page.redirects_to_external? ? '450x330' : '450x680'
            }
          }
        },
        {
          label: Alchemy.t(:copy_page),
          label_position: 'center',
          permitted: opts[:ability].can?(:copy, page),
          template_name: 'linkToRemote',
          template_locals: {
            icon: 'copy_page',
            url: routes.insert_admin_clipboard_path(
              remarkable_type: page.class.name.demodulize.underscore.pluralize,
              remarkable_id: page.id,
            ),
            method: 'POST'
          }
        },
        {
          label: Alchemy.t(:delete_page),
          label_position: 'center',
          permitted: opts[:ability].can?(:destroy, page),
          template_name: 'linkToConfirmDialog',
          template_locals: {
            icon: 'delete_page',
            url: routes.admin_page_path(page),
            options: {
              title: Alchemy.t(:please_confirm),
              message: Alchemy.t(:confirm_to_delete_page),
              ok_label: Alchemy.t('Yes'),
              cancel_label: Alchemy.t('No')
            }
          }
        },
        {
          label: Alchemy.t(:create_page),
          label_position: 'left',
          permitted: opts[:ability].can?(:create, page),
          template_name: 'linkToDialog',
          template_locals: {
            icon: 'add_page',
            url: routes.new_admin_page_path(parent_id: page.id),
            options: {
              title: Alchemy.t(:create_page),
              size: '340x165',
              overflow: true
            }
          }
        }
      ]
    end
  end
end
