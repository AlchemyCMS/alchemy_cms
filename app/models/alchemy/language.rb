# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_languages
#
#  id             :integer          not null, primary key
#  name           :string
#  language_code  :string
#  frontpage_name :string
#  page_layout    :string           default("intro")
#  public         :boolean          default(FALSE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  creator_id     :integer
#  updater_id     :integer
#  default        :boolean          default(FALSE)
#  country_code   :string           default(""), not null
#  site_id        :integer          not null
#  locale         :string
#

require_dependency "alchemy/site"

module Alchemy
  class Language < BaseRecord
    belongs_to :site
    has_many :pages, inverse_of: :language
    has_many :nodes, inverse_of: :language

    before_validation :set_locale, if: -> { locale.blank? }

    has_one :root_page, -> { where(parent: nil, layoutpage: false) }, class_name: "Alchemy::Page"

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
      if: :should_set_pages_language?

    before_destroy if: -> { pages.any? } do
      errors.add(:pages, :still_present)
      throw(:abort)
    end

    scope :published, -> { where(public: true) }
    scope :with_root_page, -> { joins(:pages).where(Page.table_name => { language_root: true }) }

    class << self
      def on_site(site)
        site ? where(site_id: site.id) : all
      end

      def on_current_site
        on_site(Site.current)
      end

      # Store the current language in the current thread.
      def current=(language)
        RequestStore.store[:alchemy_current_language] = language
      end

      # Current language from current thread or default.
      def current
        RequestStore.store[:alchemy_current_language] || default
      end

      # The root page of the current language.
      def current_root_page
        return unless current

        current.pages.language_roots.first
      end

      # Default language for current site
      def default
        on_current_site.find_by(default: true)
      end
    end

    def label(attrib)
      if attrib.to_sym == :code
        code
      else
        Alchemy.t(code, default: name)
      end
    end

    include Alchemy::Language::Code

    # All available locales matching this language
    #
    # Matching either the code (+language_code+ + +country_code+) or the +language_code+
    #
    # @return [Array]
    #
    def matching_locales
      @_matching_locales ||= ::I18n.available_locales.select do |locale|
        locale.to_s.split("-")[0] == language_code
      end
    end

    def available_menu_names
      Alchemy::Node.available_menu_names - nodes.reject(&:parent_id).map(&:menu_type)
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
        false
      else
        true
      end
    end

    def presence_of_default_language
      if Language.default == self && default_changed?
        errors.add(:default, Alchemy.t("We need at least one default."))
        false
      else
        true
      end
    end

    def remove_old_default
      lang = Language.on_site(site).default
      return true if lang.nil?

      lang.default = false
      lang.save(validate: false)
    end

    def should_set_pages_language?
      saved_change_to_language_code? || saved_change_to_country_code?
    end

    def set_pages_language
      pages.update_all language_code: code
    end
  end
end
