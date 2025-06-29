# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_pages
#
#  id               :integer          not null, primary key
#  name             :string
#  urlname          :string
#  title            :string
#  language_code    :string
#  language_root    :boolean
#  page_layout      :string
#  meta_keywords    :text
#  meta_description :text
#  lft              :integer
#  rgt              :integer
#  parent_id        :integer
#  depth            :integer
#  locked_by        :integer
#  restricted       :boolean          default(FALSE)
#  robot_index      :boolean          default(TRUE)
#  robot_follow     :boolean          default(TRUE)
#  sitemap          :boolean          default(TRUE)
#  layoutpage       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  creator_id       :integer
#  updater_id       :integer
#  language_id      :integer
#  cached_tag_list  :text
#  published_at     :datetime
#  public_on        :datetime
#  public_until     :datetime
#  locked_at        :datetime
#

require_dependency "alchemy/page/fixed_attributes"
require_dependency "alchemy/page/definitions"
require_dependency "alchemy/page/page_scopes"
require_dependency "alchemy/page/page_natures"
require_dependency "alchemy/page/page_naming"
require_dependency "alchemy/page/page_elements"

module Alchemy
  class Page < BaseRecord
    include Alchemy::Logger
    include Alchemy::Taggable

    DEFAULT_ATTRIBUTES_FOR_COPY = {
      autogenerate_elements: false,
      public_on: nil,
      public_until: nil,
      locked_at: nil,
      locked_by: nil
    }

    SKIPPED_ATTRIBUTES_ON_COPY = %w[
      id
      updated_at
      created_at
      creator_id
      updater_id
      lft
      rgt
      depth
      urlname
      cached_tag_list
    ]

    PERMITTED_ATTRIBUTES = [
      :meta_description,
      :meta_keywords,
      :name,
      :page_layout,
      :public_on,
      :public_until,
      :restricted,
      :robot_index,
      :robot_follow,
      :searchable,
      :sitemap,
      :tag_list,
      :title,
      :urlname,
      :layoutpage,
      :menu_id
    ]

    acts_as_nested_set(dependent: :destroy, scope: [:layoutpage, :language_id])

    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :language

    belongs_to :creator,
      primary_key: Alchemy.user_class_primary_key,
      class_name: Alchemy.user_class_name,
      foreign_key: :creator_id,
      optional: true

    belongs_to :updater,
      primary_key: Alchemy.user_class_primary_key,
      class_name: Alchemy.user_class_name,
      foreign_key: :updater_id,
      optional: true

    belongs_to :locker,
      primary_key: Alchemy.user_class_primary_key,
      class_name: Alchemy.user_class_name,
      foreign_key: :locked_by,
      optional: true

    has_one :site, through: :language
    has_many :site_languages, through: :site, source: :languages
    has_many :folded_pages, dependent: :destroy
    has_many :legacy_urls, class_name: "Alchemy::LegacyPageUrl", dependent: :destroy
    has_many :nodes, class_name: "Alchemy::Node", inverse_of: :page
    has_many :versions, class_name: "Alchemy::PageVersion", inverse_of: :page, dependent: :destroy
    has_one :draft_version, -> { drafts }, class_name: "Alchemy::PageVersion"
    has_one :public_version, -> { published }, class_name: "Alchemy::PageVersion", autosave: -> { persisted? }

    has_many :page_ingredients, class_name: "Alchemy::Ingredients::Page", foreign_key: :related_object_id, dependent: :nullify

    before_validation :set_language,
      if: -> { language.nil? }

    validates_presence_of :page_layout
    validates_format_of :page_layout, with: /\A[a-z0-9_-]+\z/, unless: -> { page_layout.blank? }
    validates_presence_of :parent, unless: -> { layoutpage? || language_root? }

    before_create -> { versions.build },
      if: -> { versions.none? }

    before_destroy if: -> { nodes.any? } do
      errors.add(:nodes, :still_present)
      throw(:abort)
    end

    before_save :set_language_code,
      if: -> { language.present? }

    before_save :set_restrictions_to_child_pages,
      if: :restricted_changed?

    before_save :inherit_restricted_status,
      if: -> { parent && parent.restricted? }

    before_save :set_fixed_attributes,
      if: -> { fixed_attributes.any? }

    after_update :create_legacy_url,
      if: :saved_change_to_urlname?

    after_update :touch_nodes

    # Concerns
    include Definitions
    include PageScopes
    include PageNatures
    include PageNaming
    include PageElements

    # site_name accessor
    delegate :name, to: :site, prefix: true, allow_nil: true
    delegate :has_hint?, :hint, to: :definition

    # Class methods
    #
    class << self
      # The url_path class
      # @see Alchemy::Page::UrlPath
      def url_path_class
        @_url_path_class ||= Alchemy::Page::UrlPath
      end

      # Set a custom url path class
      #
      #     # config/initializers/alchemy.rb
      #     Alchemy::Page.url_path_class = MyPageUrlPathClass
      #
      def url_path_class=(klass)
        @_url_path_class = klass
      end

      def searchable_alchemy_resource_attributes
        %w[name urlname title]
      end

      # @return the language root page for given language id.
      # @param language_id [Fixnum]
      #
      def language_root_for(language_id)
        language_roots.find_by_language_id(language_id)
      end

      # Creates a copy of given source.
      #
      # Also copies all elements included in source.
      #
      # === Note:
      #
      # It prevents the element auto generator from running.
      #
      # @param source [Alchemy::Page]
      #   The source page the copy is taken from
      # @param differences [Hash]
      #   A optional hash with attributes that take precedence over the source attributes
      #
      # @return [Alchemy::Page]
      #
      def copy(source, differences = {})
        Alchemy::CopyPage.new(page: source).call(changed_attributes: differences)
      end

      def copy_and_paste(source, new_parent, new_name)
        page = Alchemy::CopyPage.new(page: source)
          .call(changed_attributes: {
            parent: new_parent,
            language: new_parent&.language,
            name: new_name,
            title: new_name
          })
        if source.children.any?
          source.copy_children_to(page)
        end
        page
      end

      def all_from_clipboard(clipboard)
        return [] if clipboard.blank?

        where(id: clipboard.collect { |p| p["id"] })
      end

      def all_from_clipboard_for_select(clipboard, language_id, layoutpages: false)
        return [] if clipboard.blank?

        clipboard_pages = all_from_clipboard(clipboard)
        allowed_page_layouts = Alchemy::Page.selectable_layouts(language_id, layoutpages: layoutpages)
        allowed_page_layout_names = allowed_page_layouts.collect(&:name)
        clipboard_pages.select { |cp| allowed_page_layout_names.include?(cp.page_layout) }
      end

      def link_target_options
        options = [[Alchemy.t(:default, scope: "link_target_options"), ""]]
        link_target_options = Alchemy.config.link_target_options
        link_target_options.each do |option|
          # add an underscore to the options to provide the default syntax
          # @link https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a#target
          options << [Alchemy.t(option, scope: "link_target_options",
            default: option.to_s.humanize), "_#{option}"]
        end
        options
      end

      # Allow all string and text attributes to be searchable by Ransack.
      def ransackable_attributes(_auth_object = nil)
        searchable_alchemy_resource_attributes + ["updated_at"]
      end
    end

    # Instance methods
    #

    # Returns elements from pages public version.
    #
    # You can pass another page_version to load elements from in the options.
    #
    # @option options [Array<String>|String] :only
    #   Returns only elements with given names
    # @option options [Array<String>|String] :except
    #   Returns all elements except the ones with given names
    # @option options [Integer] :count
    #   Limit the count of returned elements
    # @option options [Integer] :offset
    #   Starts with an offset while returning elements
    # @option options [Boolean] :include_hidden (false)
    #   Return hidden elements as well
    # @option options [Boolean] :random (false)
    #   Return elements randomly shuffled
    # @option options [Boolean] :reverse (false)
    #   Reverse the load order
    # @option options [Class] :finder (Alchemy::ElementsFinder)
    #   A class that will return elements from page.
    #   Use this for your custom element loading logic.
    # @option options [Alchemy::PageVersion] :page_version
    #   A page version to load elements from.
    #   Uses the pages public_version by default.
    #
    # @return [ActiveRecord::Relation]
    def find_elements(options = {})
      finder = options[:finder] || Alchemy::ElementsFinder.new(options)
      finder.elements(page_version: options[:page_version] || public_version)
    end

    # = The url_path for this page
    #
    # @see Alchemy::Page::UrlPath#call
    def url_path
      self.class.url_path_class.new(self).call
    end

    # The page's view partial is dependent from its page layout
    #
    # == Define page layouts
    #
    # Page layouts are defined in the +config/alchemy/page_layouts.yml+ file
    #
    #     - name: contact
    #       elements: [contactform]
    #       ...
    #
    # == Override the view
    #
    # Page layout partials live in +app/views/alchemy/page_layouts+
    #
    def to_partial_path
      "alchemy/page_layouts/#{layout_partial_name}"
    end

    # Returns the previous page on the same level or nil.
    #
    # @option options [Boolean] :restricted (false)
    #   only restricted pages (true), skip restricted pages (false)
    # @option options [Boolean] :public (true)
    #   only public pages (true), skip public pages (false)
    #
    def previous(options = {})
      pages = self_and_siblings.where("lft < ?", lft)
      select_page(pages, options.merge(order: :desc))
    end

    alias_method :previous_page, :previous

    # Returns the next page on the same level or nil.
    #
    # @option options [Boolean] :restricted (false)
    #   only restricted pages (true), skip restricted pages (false)
    # @option options [Boolean] :public (true)
    #   only public pages (true), skip public pages (false)
    #
    def next(options = {})
      pages = self_and_siblings.where("lft > ?", lft)
      select_page(pages, options.merge(order: :asc))
    end

    alias_method :next_page, :next

    # Locks the page to given user
    #
    def lock_to!(user)
      update_columns(locked_at: Time.current, locked_by: user.id)
    end

    # Unlocks the page without updating the timestamps
    #
    def unlock!
      if update_columns(locked_at: nil, locked_by: nil)
        Current.preview_page = nil
      end
    end

    def fold!(user_id, status)
      folded_page = folded_pages.find_or_create_by(user_id: user_id)
      folded_page.folded = status
      folded_page.save!
    end

    def set_restrictions_to_child_pages
      descendants.each do |child|
        child.update(restricted: restricted?)
      end
    end

    def inherit_restricted_status
      self.restricted = parent.restricted?
    end

    # Returns the first published child
    def first_public_child
      children.published.first
    end

    # Gets the language_root page for page
    def get_language_root
      self_and_ancestors.find_by(language_root: true)
    end

    def copy_children_to(new_parent)
      children.each do |child|
        next if child == new_parent

        new_child = Alchemy::CopyPage.new(page: child).call(changed_attributes: {
          parent_id: new_parent.id,
          language_id: new_parent.language_id,
          language_code: new_parent.language_code
        })
        new_child.move_to_child_of(new_parent)
        child.copy_children_to(new_child) unless child.children.blank?
      end
    end

    # Creates a public version of the page in the background.
    #
    def publish!(current_time = Time.current)
      PublishPageJob.perform_later(id, public_on: current_time)
    end

    # Sets the public_on date on the published version
    #
    # Builds a new version if none exists yet.
    # Destroys public version if empty time is set
    #
    def public_on=(time)
      if public_version && time.blank?
        public_version.destroy!
        # Need to reset the public version on the instance so we do not need to reload
        self.public_version = nil
      elsif public_version
        public_version.public_on = time
      elsif time.present?
        versions.build(public_on: time)
      end
    end

    delegate :public_until=, to: :public_version, allow_nil: true

    # Holds an instance of +FixedAttributes+
    def fixed_attributes
      @_fixed_attributes ||= FixedAttributes.new(self)
    end

    # True if given attribute name is defined as fixed
    def attribute_fixed?(name)
      fixed_attributes.fixed?(name)
    end

    # Checks the current page's list of editors, if defined.
    #
    # This allows us to pass in a user and see if any of their roles are enable
    # them to make edits
    #
    def editable_by?(user)
      return true unless has_limited_editors?

      (editor_roles & user.alchemy_roles).any?
    end

    # Returns the value of +public_on+ attribute from public version
    #
    # If it's a fixed attribute then the fixed value is returned instead
    #
    def public_on
      attribute_fixed?(:public_on) ? fixed_attributes[:public_on] : public_version&.public_on
    end

    # Returns the value of +public_until+ attribute
    #
    # If it's a fixed attribute then the fixed value is returned instead
    #
    def public_until
      attribute_fixed?(:public_until) ? fixed_attributes[:public_until] : public_version&.public_until
    end

    # Returns the name of the creator of this page.
    #
    # If no creator could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def creator_name
      creator.try(:alchemy_display_name) || Alchemy.t("unknown")
    end

    # Returns the name of the last updater of this page.
    #
    # If no updater could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def updater_name
      updater.try(:alchemy_display_name) || Alchemy.t("unknown")
    end

    # Returns the name of the user currently editing this page.
    #
    # If no locker could be found or associated user model
    # does not respond to +#name+ it returns +'unknown'+
    #
    def locker_name
      locker.try(:alchemy_display_name) || Alchemy.t("unknown")
    end

    # Key hint translations by page layout, rather than the default name.
    #
    def hint_translation_attribute
      page_layout
    end

    # Menus (aka. root nodes) this page is attached to
    #
    def menus
      @_menus ||= nodes.map(&:root)
    end

    private

    def set_fixed_attributes
      fixed_attributes.all.each do |attribute, value|
        send(:"#{attribute}=", value)
      end
    end

    def select_page(pages, options = {})
      pages = options.fetch(:public, true) ? pages.published : pages.not_public
      pages.where(restricted: options.fetch(:restricted, false))
        .reorder(lft: options.fetch(:order))
        .limit(1).first
    end

    def set_language
      self.language = parent&.language || Current.language
      set_language_code
    end

    def set_language_code
      self.language_code = language.code
    end

    # Stores the old urlname in a LegacyPageUrl
    def create_legacy_url
      legacy_urls.find_or_create_by(urlname: urlname_before_last_save)
    end

    def touch_nodes
      ids = node_ids + nodes.flat_map { |n| n.ancestors.pluck(:id) }
      Node.where(id: ids).touch_all
    end
  end
end
