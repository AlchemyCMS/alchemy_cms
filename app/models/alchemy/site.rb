module Alchemy
  class Site < ActiveRecord::Base
    cattr_accessor :current

    attr_accessible :host, :name, :public

    # validations
    validates_presence_of :host
    validates_uniqueness_of :host

    # associations
    has_many :languages

    scope :published, where(public: true)

    # Returns true if this site is the current site
    def current?
      self.class.current == self
    end

    class << self
      def default
        Site.first
      end
    end

    before_create do
      # If no languages are present, create a default language based
      # on the host app's Alchemy configuration.

      if languages.empty?
        default_language = Alchemy::Config.get(:default_language)
        languages.build(
          name:           default_language['name'],
          language_code:  default_language['code'],
          frontpage_name: default_language['frontpage_name'],
          page_layout:    default_language['page_layout'],
          public:         true,
          default:        true
        )
      end
    end
  end
end
