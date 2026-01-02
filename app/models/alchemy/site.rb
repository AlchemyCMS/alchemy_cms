# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_sites
#
#  id                       :integer          not null, primary key
#  host                     :string
#  name                     :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  public                   :boolean          default(FALSE)
#  aliases                  :text
#  redirect_to_primary_host :boolean
#

module Alchemy
  class Site < BaseRecord
    # validations
    validates_presence_of :host
    validates_uniqueness_of :host, case_sensitive: false

    # associations
    has_many :languages, dependent: :restrict_with_error

    scope :published, -> { where(public: true) }

    # concerns
    include Alchemy::Site::Layout

    # Returns true if this site is the current site
    def current?
      Current.site == self
    end

    # Returns the path to site's view partial.
    #
    # Site view partials live in +app/views/alchemy/site_layouts+
    #
    # Please use <tt>rails g alchemy:site_layouts</tt> to generate partials for all your sites.
    #
    def to_partial_path
      "alchemy/site_layouts/#{partial_name}"
    end

    # The default language for this site
    #
    # There can only be one default language per site.
    #
    def default_language
      languages.find_by(default: true)
    end

    # Returns true if the given user has access to this site.
    # A site is accessible by all users if no roles are specified.
    #
    def accessible_by?(user)
      return false if user.nil?

      (accessible_by & user.alchemy_roles).any? || accessible_by.empty?
    end

    # Returns an array of role names that are allowed to access this site.
    #
    def accessible_by
      definition.fetch("accessible_by", [])
    end

    class << self
      def find_for_host(host)
        # These are split up into two separate queries in order to run the
        # fastest query first (selecting the domain by its primary host name).
        #
        find_by(host: host) || find_in_aliases(host) || first
      end

      def find_in_aliases(host)
        return nil if host.blank?

        all.find do |site|
          site.aliases.split.include?(host) if site.aliases.present?
        end
      end

      def accessible_by(user)
        all.select { |site| site.accessible_by?(user) }
      end
    end
  end
end
