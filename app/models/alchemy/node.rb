# frozen_string_literal: true

module Alchemy
  class Node < BaseRecord
    VALID_URL_REGEX = /\A(\/|\D[a-z\+\d\.\-]+:)/

    acts_as_nested_set scope: 'language_id', touch: true
    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :site, class_name: 'Alchemy::Site'
    belongs_to :language, class_name: 'Alchemy::Language'
    belongs_to :page, class_name: 'Alchemy::Page', optional: true, inverse_of: :nodes

    validates :name, presence: true, if: -> { page.nil? }
    validates :url, format: { with: VALID_URL_REGEX }, unless: -> { url.nil? }

    # Returns the name
    #
    # Either the value is stored in the database
    # or, if attached, the values comes from a page.
    def name
      read_attribute(:name).presence || page&.name
    end

    class << self
      # Returns all root nodes for current language
      def language_root_nodes
        raise 'No language found' if Language.current.nil?

        roots.where(language_id: Language.current.id)
      end

      def available_menu_names
        read_definitions_file
      end

      private

      # Reads the element definitions file named +menus.yml+ from +config/alchemy/+ folder.
      #
      def read_definitions_file
        if ::File.exist?(definitions_file_path)
          ::YAML.safe_load(File.read(definitions_file_path)) || []
        else
          raise LoadError, "Could not find menus.yml file! Please run `rails generate alchemy:install`"
        end
      end

      # Returns the +menus.yml+ file path
      #
      def definitions_file_path
        Rails.root.join 'config/alchemy/menus.yml'
      end
    end

    # Returns the url
    #
    # Either the value is stored in the database, aka. an external url.
    # Or, if attached, the values comes from a page.
    def url
      page && "/#{page.urlname}" || read_attribute(:url).presence
    end

    def to_partial_path
      "#{view_folder_name}/wrapper"
    end

    def view_folder_name
      "alchemy/menus/#{name.parameterize.underscore}"
    end
  end
end
