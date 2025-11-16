# frozen_string_literal: true

module Alchemy
  class PageTreeSerializer < BaseSerializer
    def attributes
      {"pages" => nil}
    end

    def pages
      base_level = object.level - 1
      build_pages_tree([object], base_level)
    end

    private

    def build_pages_tree(pages, level)
      pages.map do |page|
        # Use association target directly to avoid triggering queries
        children = page.association(:children).loaded? ? page.association(:children).target : []
        has_children = children.any?
        folded = !has_children && !page.leaf?

        page_hash(page, level, folded).tap do |hash|
          hash[:children] = build_pages_tree(children, level + 1)
        end
      end
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
        children: []
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
          status_titles: page_status_titles(page)
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
        edit_content: ability.can?(:edit_content, page)
      }
    end

    def page_status_titles(page)
      {
        public: page.status_title(:public),
        restricted: page.status_title(:restricted),
        locked: page.status_title(:locked)
      }
    end
  end
end
