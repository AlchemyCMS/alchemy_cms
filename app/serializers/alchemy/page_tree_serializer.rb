# frozen_string_literal: true

module Alchemy
  class PageTreeSerializer < Panko::Serializer
    attributes(
      :id,
      :name,
      :public,
      :visible,
      :folded,
      :locked,
      :restricted,
      :page_layout,
      :redirects_to_external,
      :urlname,
      :level,
      :external_urlname,
      :root,
      :definition_missing,
      :locked_notice,
      :permissions,
      :status_titles,
      :has_children
    )

    private

    def has_children
      object.children.any?
    end

    def public
      object.public?
    end

    def visible
      object.visible?
    end

    def folded
      object.folded_pages.any? { |p| p.user_id == scope[:user].id }
    end

    def locked
      object.locked?
    end

    def restricted
      object.restricted?
    end

    def redirects_to_external
      object.redirects_to_external?
    end

    def level
      object.depth - 1
    end

    def external_urlname
      object.redirects_to_external? ? object.external_urlname : nil
    end

    def root
      level == 0
    end

    def definition_missing
      object.definition.blank?
    end

    def locked_notice
      object.locked? ? Alchemy.t('This page is locked', name: object.locker_name) : nil
    end

    def permissions
      page_permissions(object, scope[:ability])
    end

    def status_titles
      page_status_titles(object)
    end

  #   def initialize(object, opts = {})
  #     tree = []
  #     path = [{id: object.parent_id, children: tree}]
  #     page_list = object.self_and_descendants
  #     base_level = object.level - 1
  #     # Load folded pages in advance
  #     folded_user_pages = FoldedPage.folded_for_user(opts[:user]).pluck(:page_id)
  #     folded_depth = Float::INFINITY

  #     page_list.each_with_index do |page, i|
  #       has_children = page_list[i + 1] && page_list[i + 1].parent_id == page.id
  #       folded = has_children && folded_user_pages.include?(page.id)

  #       if page.depth > folded_depth
  #         next
  #       else
  #         folded_depth = Float::INFINITY
  #       end

  #       # If this page is folded, skip all pages that are on a higher level (further down the tree).
  #       if folded && !opts[:full]
  #         folded_depth = page.depth
  #       end

  #       if page.parent_id != path.last[:id]
  #         if path.map { |o| o[:id] }.include?(page.parent_id) # Lower level
  #           path.pop while path.last[:id] != page.parent_id
  #         else # One level up
  #           path << path.last[:children].last
  #         end
  #       end

  #       level = path.count + base_level

  #       path.last[:children] << page_hash(page, has_children, level, folded, opts)
  #     end

  #     @subjects = tree
  #   end

  #   protected

  #   def page_hash(page, has_children, level, folded, opts)
  #     p_hash = {
  #       id: page.id,
  #       name: page.name,
  #       public: page.public?,
  #       visible: page.visible?,
  #       restricted: page.restricted?,
  #       page_layout: page.page_layout,
  #       slug: page.slug,
  #       redirects_to_external: page.redirects_to_external?,
  #       urlname: page.urlname,
  #       external_urlname: page.redirects_to_external? ? page.external_urlname : nil,
  #       level: level,
  #       root: level == 1,
  #       root_or_leaf: level == 1 || !has_children,
  #       children: []
  #     }

  #     if opts[:elements]
  #       p_hash.update(elements: ActiveModel::ArraySerializer.new(page_elements(page)))
  #     end

  #     if opts[:ability].can?(:index, :alchemy_admin_pages)
  #       p_hash.merge({
  #         definition_missing: page.definition.blank?,
  #         folded: folded,
  #         locked: page.locked?,
  #         locked_notice: page.locked? ? Alchemy.t('This page is locked', name: page.locker_name) : nil,
  #         permissions: page_permissions(page, opts[:ability]),
  #         status_titles: page_status_titles(page)
  #       })
  #     else
  #       p_hash
  #     end
  #   end

  #   def page_elements(page)
  #     if opts[:elements] == 'true'
  #       page.elements
  #     else
  #       page.elements.named(opts[:elements].split(',') || [])
  #     end
  #   end

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
        visible: page.status_title(:visible),
        restricted: page.status_title(:restricted)
      }
    end
  end
end
