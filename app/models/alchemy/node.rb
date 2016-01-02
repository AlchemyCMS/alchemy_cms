module Alchemy
  class Node < ActiveRecord::Base
    acts_as_nested_set scope: 'language_id'

    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :navigatable, polymorphic: true
    belongs_to :language

    validates :name,
      presence: true

    validates :language,
      presence: true

    scope :with_language,
      ->(language) { where(language_id: language.id) }

    # Class methods
    class << self

      # Returns all root nodes for current language
      def language_root_nodes
        raise 'No language found' if Language.current.nil?
        Node.roots.with_language(Language.current)
      end
    end

    # Returns true if this node is a root node
    def root?
      parent_id.nil?
    end

    # Returns the url of the attached navigatable or nil
    def url
      navigatable.try(:alchemy_node_url) ||
        read_attribute(:url)
    end
  end
end
