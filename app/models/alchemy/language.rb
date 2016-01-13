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
    belongs_to :site
    has_many :pages

    before_validation :set_locale, if: -> { locale.blank? }

    validates :name, presence: true
    validates :page_layout, presence: true
    validates :frontpage_name, presence: true

    validates :language_code,
      presence: true,
      uniqueness: { scope: [:site_id, :country_code] },
      format: { with: /\A[a-z]{2}\z/, if: -> { language_code.present? } }

    validates :country_code,
      format: { with: /\A[a-zA-Z]{2}\z/, if: -> { country_code.present? } }

    validate :presence_of_default_language
    validate :publicity_of_default_language
    validate :presence_of_locale_file, if: -> { language_code.present? }

    before_save :remove_old_default,
      if: -> { default_changed? && self != Language.default }

    after_update :set_pages_language,
      if: -> { language_code_changed? || country_code_changed? }

    after_update :unpublish_pages,
      if: -> { changes[:public] == [true, false] }

    before_destroy :check_for_default
    after_destroy :delete_language_root_page

    default_scope { on_site(Site.current) }

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

      # The root page of the current language.
      def current_root_page
        current.pages.language_roots.first
      end

      # Default language
      def default
        find_by(default: true)
      end
      alias_method :get_default, :default
    end

    def label(attrib)
      if attrib.to_sym == :code
        code
      else
        Alchemy.t(code, default: name)
      end
    end

    include Alchemy::Language::Code

    # Root page
    def root_page
      @root_page ||= pages.language_roots.first
    end

    # Layout root page
    def layout_root_page
      @layout_root_page ||= Page.layout_root_for(id)
    end

    # All available locales matching this language
    #
    # Matching either the code (+language_code+ + +country_code+) or the +language_code+
    #
    # @return [Array]
    #
    def matching_locales
      @_matching_locales ||= ::I18n.available_locales.select do |locale|
        locale.to_s.split('-')[0] == language_code
      end
    end

    private

    def set_locale
      self.locale = matching_locales.reverse.detect do |locale|
        locale.to_s == code || locale.to_s == language_code
      end
    end

    def presence_of_locale_file
      if locale.nil?
        errors.add(:locale, :missing_file)
      end
    end

    def publicity_of_default_language
      if default? && !public?
        errors.add(:public, Alchemy.t("Default language has to be public"))
        return false
      else
        return true
      end
    end

    def presence_of_default_language
      if Language.default == self && default_changed?
        errors.add(:default, Alchemy.t("We need at least one default."))
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

    def set_pages_language
      pages.update_all language_code: code
    end

    def check_for_default
      raise DefaultLanguageNotDeletable if default?
    end

    def delete_language_root_page
      root_page.try(:destroy) && layout_root_page.try(:destroy)
    end

    def unpublish_pages
      pages.update_all(public_on: nil, public_until: nil)
    end
  end
end
