module Alchemy
  class Node < ActiveRecord::Base
    acts_as_nested_set scope: 'language_id'
    stampable stamper_class_name: Alchemy.user_class_name

    belongs_to :navigatable, polymorphic: true
    belongs_to :language

    validates :name,
      presence: true

    before_save :update_navigatable,
      if: -> { navigatable }

    after_save :update_url,
      if: -> { parent }

    after_update :update_descendants_urlnames,
      if: -> { url_changed? }

    # TODO implement after_move :update_url
    # after_move :update_url,
    #   unless: :redirects_to_external?

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

    # Returns true if this node is a root node
    def root?
      parent_id.nil?
    end

    # Returns the last part of the nodes url path
    def slug
      @slug ||= url.to_s.split('/').last
    end

    # Updates url attribute to be a path including parent urls.
    def update_url
      new_url = [parent.url.presence, self.slug].compact.join('/')
      if self.url != new_url
        update_column(:url, new_url)
      end
    end

    # Called from nodes controller, if navigatable_id is 'create'
    def create_navigatable!
      return if navigatable_type.blank?
      klass = navigatable_type.constantize
      if klass.respond_to?(:create_from_alchemy_node)
        self.navigatable = klass.create_from_alchemy_node(self)
        self.save!
      end
    end

    private

    def update_navigatable
      if self.navigatable.respond_to?(:before_save_of_alchemy_node)
        self.navigatable.send(:before_save_of_alchemy_node, self)
      end
    end

    def update_descendants_urlnames
      descendants.each do |descendant|
        # TODO implement redirects_toexternal?
        # next if descendant.redirects_to_external?
        descendant.update_url
      end
    end

  end
end
