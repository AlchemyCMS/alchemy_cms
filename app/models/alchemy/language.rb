module Alchemy
  class Language < ActiveRecord::Base

    attr_accessible(
      :name,
      :language_code,
      :frontpage_name,
      :page_layout,
      :public,
      :default,
      :country_code,
      :code,
      :site
    )

    validates_presence_of :name
    validates_presence_of :language_code
    validates_presence_of :page_layout
    validates_presence_of :frontpage_name
    validates_uniqueness_of :language_code, :scope => [:site_id, :country_code]
    validate :presence_of_default_language
    validate :publicity_of_default_language
    has_many :pages
    belongs_to :site
    after_destroy :delete_language_root_page
    validates_format_of :language_code, with: /\A[a-z]{2}\z/, if: -> { language_code.present? }
    validates_format_of :country_code, with: /\A[a-z]{2}\z/, if: -> { country_code.present? }
    before_destroy :check_for_default
    after_update :set_pages_language, :if => proc { |m| m.language_code_changed? || m.country_code_changed? }
    after_update :unpublish_pages, :if => proc { changes[:public] == [true, false] }
    before_save :remove_old_default, :if => proc { |m| m.default_changed? && m != Language.get_default }

    scope :published,          -> { where(public: true) }
    scope :with_language_root, -> { joins(:pages).where('alchemy_pages' => {language_root: true}) }
    scope :on_site,            ->(s) { s.present? ? where(site_id: s) : scoped }
    default_scope { on_site(Site.current) }

    class << self

      # Returns all languages for which a language root page exists.
      def all_for_created_language_trees
        # don't use 'find' here as it would clash with our default_scopes
        # in various unholy ways you don't want to find out about.
        where(id: Page.language_roots.collect(&:language_id))
      end

      def all_codes_for_published
        published.collect(&:code)
      rescue
        []
      end

      def get_default
        where(default: true).first
      end

    end

    def label(attrib)
      if attrib.to_sym == :code
        self.code
      else
        I18n.t(self.code, :default => self.name)
      end
    end

    include Code

  private

    def publicity_of_default_language
      if self.default? && !self.public?
        errors.add(:base, I18n.t("Default language has to be public"))
        return false
      else
        return true
      end
    end

    def presence_of_default_language
      if Language.get_default == self && self.default_changed?
        errors.add(:base, I18n.t("We need at least one default."))
        return false
      else
        return true
      end
    end

    def remove_old_default
      lang = Language.on_site(site).get_default
      return true if lang.nil?
      lang.default = false
      lang.save(:validate => false)
    end

    def set_pages_language
      pages.update_all :language_code => self.code
    end

    def check_for_default
      raise "Default language is not deletable" if self.default?
    end

    def delete_language_root_page
      page = Page.language_root_for(id)
      page.destroy if page
      layoutroot = Page.layout_root_for(id)
      layoutroot.destroy if layoutroot
    end

    def unpublish_pages
      self.pages.update_all(:public => false)
    end

  end
end
