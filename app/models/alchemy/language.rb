# == Schema Information
#
# Table name: alchemy_languages
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  language_code  :string(255)
#  frontpage_name :string(255)
#  page_layout    :string(255)      default("intro")
#  public         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  creator_id     :integer
#  updater_id     :integer
#  default        :boolean          default(FALSE)
#  country_code   :string(255)      default(""), not null
#  site_id        :integer
#

module Alchemy
  class Language < ActiveRecord::Base
    validates :name, presence: true
    validates :page_layout, presence: true
    validates :frontpage_name, presence: true
    validates :country_code, format: {
        with: /\A[a-z]{2}\z/,
        if: -> { country_code.present? }
      }
    validates :language_code,
      presence: true,
      uniqueness: {
        scope: [:site_id, :country_code]
      },
      format: {
        with: /\A[a-z]{2}\z/,
        if: -> { language_code.present? }
      }
    validate :ensure_presence_of_default_language
    validate :ensure_publicity_of_default_language

    belongs_to :site
    has_many :nodes, dependent: :destroy
    has_many :pages, dependent: :destroy

    before_save :remove_old_default,
      if: -> { default_changed? && self != Language.default }
    after_update :update_pages_language_code,
      if: -> { language_code_changed? || country_code_changed? }
    after_update :unpublish_pages,
      if: -> { changes[:public] == [true, false] }
    before_destroy :check_for_default

    default_scope { on_site(Site.current) }

    scope :published,      -> { where(public: true) }
    scope :with_root_page, -> { joins(:pages).where(alchemy_pages: {language_root: true}) }
    scope :on_site,        ->(s) { s.present? ? where(site_id: s) : all }

    scope :published,      -> { where(public: true) }
    scope :with_root_page, -> { joins(:pages).where(Page.table_name => {language_root: true}) }
    scope :on_site,        ->(s) { s.present? ? where(site_id: s.id) : all }

    class << self

      # Store the current language in the current thread.
      def current=(v)
        RequestStore.store[:alchemy_current_language] = v
      end

      # Current language from current thread or default.
      def current
        RequestStore.store[:alchemy_current_language] || default
      end

      # The root node of the current language.
      def current_root_node
        current_root_nodes.first
      end

      # All root nodes of the current language.
      def current_root_nodes
        current.nodes.roots
      end

      # Default language
      def default
        find_by(default: true)
      end
      alias_method :get_default, :default
    end

    def label(attrib)
      if attrib.to_sym == :code
        self.code
      else
        I18n.t(self.code, default: self.name)
      end
    end

    include Alchemy::Language::Code

    # Root node
    def root_node
      @root_node ||= nodes.root
    end

    # All root nodes
    def root_nodes
      @root_nodes ||= nodes.roots
    end

    private

    def ensure_publicity_of_default_language
      if self.default? && !self.public?
        errors.add(:public, I18n.t("Default language has to be public"))
        return false
      else
        return true
      end
    end

    def ensure_presence_of_default_language
      if Language.default == self && self.default_changed?
        errors.add(:default, I18n.t("We need at least one default language."))
        return false
      else
        return true
      end
    end

    def remove_old_default
      lang = Language.on_site(site).default
      return true if lang.nil?
      lang.default = false
      lang.save(validate: false)
    end

    def update_pages_language_code
      pages.update_all(language_code: self.code)
    end

    def check_for_default
      raise DefaultLanguageNotDeletable if default?
    end

    def unpublish_pages
      self.pages.update_all(public: false)
    end
  end
end
