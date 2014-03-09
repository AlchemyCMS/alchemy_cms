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
    validates_presence_of :name
    validates_presence_of :language_code
    validates_presence_of :page_layout
    validates_presence_of :frontpage_name
    validates_uniqueness_of :language_code, scope: [:site_id, :country_code]
    validate :presence_of_default_language
    validate :publicity_of_default_language
    has_many :pages
    belongs_to :site
    after_destroy :delete_language_root_page
    validates_format_of :language_code, with: /\A[a-z]{2}\z/, if: -> { language_code.present? }
    validates_format_of :country_code, with: /\A[a-z]{2}\z/, if: -> { country_code.present? }
    before_destroy :check_for_default
    after_update :set_pages_language, if: proc { |m| m.language_code_changed? || m.country_code_changed? }
    after_update :unpublish_pages, if: proc { changes[:public] == [true, false] }
    before_save :remove_old_default, if: proc { |m| m.default_changed? && m != Language.default }

    scope :published,      -> { where(public: true) }
    scope :with_root_page, -> { joins(:pages).where(alchemy_pages: {language_root: true}) }
    scope :on_site,        ->(s) { s.present? ? where(site_id: s) : all }
    default_scope { on_site(Site.current) }

    class << self

      # Store the current language in the current thread.
      def current=(v)
        Thread.current[:alchemy_current_language] = v
      end

      # Current language from current thread or default.
      def current
        Thread.current[:alchemy_current_language] || default
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
        self.code
      else
        I18n.t(self.code, default: self.name)
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

    private

    def publicity_of_default_language
      if self.default? && !self.public?
        errors.add(:public, I18n.t("Default language has to be public"))
        return false
      else
        return true
      end
    end

    def presence_of_default_language
      if Language.default == self && self.default_changed?
        errors.add(:default, I18n.t("We need at least one default."))
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
      pages.update_all language_code: self.code
    end

    def check_for_default
      raise "Default language is not deletable" if self.default?
    end

    def delete_language_root_page
      root_page.try(:destroy) && layout_root_page.try(:destroy)
    end

    def unpublish_pages
      self.pages.update_all(public: false)
    end

  end
end
