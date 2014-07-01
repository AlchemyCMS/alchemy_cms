module Alchemy
  class Node < ActiveRecord::Base
    acts_as_nested_set scope: 'language_id'
    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :navigatable, polymorphic: true
    belongs_to :language

    validates :name, presence: true

    # Class methods
    class << self

      # Returns all root nodes for current language
      def language_root_nodes
        raise 'No language found' if Language.current.nil?
        Node.where(parent_id: nil, language_id: Language.current.id)
      end

      def create_language_root_node!
        raise 'No language found' if Language.current.nil?
        Node.create!(
          parent_id: nil,
          name: I18n.t('Main Navigation'),
          language_id: Language.current.id
        )
      end

    end

    # Returns the the url value.
    # Either the value is stored in the database, aka. an external url.
    # Or, if attached, the values comes from a navigatable.
    def url
      read_attribute(:url) || navigatable.try(:to_param)
    end

    # Returns true if this node is a root node
    def root?
      parent_id.nil?
    end
  end
end
