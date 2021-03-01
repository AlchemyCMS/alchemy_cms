# frozen_string_literal: true

module Alchemy
  class PageTreeSerializer < BaseSerializer
    def attributes
      {"pages" => nil}
    end

    def pages
      tree = []
      path = [{id: object.parent_id, children: tree}]
      page_list = object.self_and_descendants
      base_level = object.level - 1
      # Load folded pages in advance
      folded_user_pages = FoldedPage.folded_for_user(opts[:user]).pluck(:page_id)
      folded_depth = Float::INFINITY

      page_list.each_with_index do |page, i|
        has_children = page_list[i + 1] && page_list[i + 1].parent_id == page.id
        folded = has_children && folded_user_pages.include?(page.id)

        if page.depth > folded_depth
          next
        else
          folded_depth = Float::INFINITY
        end

        # If this page is folded, skip all pages that are on a higher level (further down the tree).
        if folded && !opts[:full]
          folded_depth = page.depth
        end

        if page.parent_id != path.last[:id]
          if path.map { |o| o[:id] }.include?(page.parent_id) # Lower level
            path.pop while path.last[:id] != page.parent_id
          else # One level up
            path << path.last[:children].last
          end
        end

        level = path.count + base_level

        path.last[:children] << page_hash(page, level, folded)
      end

      tree
    end

    protected

    def page_hash(page, level, folded)
      p_hash = {
        id: page.id,
        name: page.name,
        public: page.public?,
        restricted: page.restricted?,
        page_layout: page.page_layout,
        slug: page.slug,
        urlname: page.urlname,
        url_path: page.url_path,
        level: level,
        root: page.root?,
        root_or_leaf: page.root? || page.leaf?,
        children: [],
      }

      if opts[:elements]
        p_hash.update(elements: ActiveModel::Serializer::CollectionSerializer.new(page_elements(page)))
      end

      if opts[:ability].can?(:index, :alchemy_admin_pages)
        p_hash.merge({
          definition_missing: page.definition.blank?,
          folded: folded,
          locked: page.locked?,
          locked_notice: page.locked? ? Alchemy.t("This page is locked", name: page.locker_name) : nil,
          permissions: page_permissions(page, opts[:ability]),
          status_titles: page_status_titles(page),
        })
      else
        p_hash
      end
    end

    def page_elements(page)
      elements = page.public_version&.elements || Alchemy::Element.none
      if opts[:elements] == "true"
        elements
      else
        elements.named(opts[:elements].split(",") || [])
      end
    end

    def page_permissions(page, ability)
      {
        info: ability.can?(:info, page),
        configure: ability.can?(:configure, page),
        copy: ability.can?(:copy, page),
        destroy: ability.can?(:destroy, page),
        create: ability.can?(:create, Alchemy::Page),
        edit_content: ability.can?(:edit_content, page),
      }
    end

    def page_status_titles(page)
      {
        public: page.status_title(:public),
        restricted: page.status_title(:restricted),
      }
    end
  end
end
