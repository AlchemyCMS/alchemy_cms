module Alchemy
  module UserMethods
    extend ActiveSupport::Concern

    included do
      # Unlock all locked pages before destroy.
      before_destroy :unlock_pages!

      scope :alchemy_admins, -> { with_alchemy_role(:admin) }

      scope :with_alchemy_role, ->(role) {
        role = role.to_s.downcase
        unless Alchemy.config.user_roles.include?(role)
          Alchemy::Logger.warn("Unknown Alchemy role: #{role.inspect}")
        end

        col = arel_table[:alchemy_roles]
        where(
          col.eq(role)
            .or(col.matches("#{role} %"))
            .or(col.matches("% #{role} %"))
            .or(col.matches("% #{role}"))
        )
      }

      validates :alchemy_roles,
        presence: true,
        inclusion: {
          in: Alchemy.config.user_roles,
          message: "is not included in #{Alchemy.config.user_roles.join(", ")}"
        }

      # Returns all pages locked by user.
      #
      # A page gets locked when the user starts to edit the page.
      #
      has_many :locked_pages,
        -> { order(:locked_at) },
        foreign_key: :locked_by,
        class_name: "Alchemy::Page",
        inverse_of: :locker
    end

    class_methods do
      def human_alchemy_rolename(role)
        Alchemy.t("user_roles.#{role}")
      end
    end

    def alchemy_admin?
      has_alchemy_role?("admin")
    end

    def alchemy_roles
      read_attribute(:alchemy_roles).split(" ")
    end

    def alchemy_roles=(roles)
      roles = Array(roles).map { _1.to_s.strip }
      roles.reject!(&:blank?)
      roles.uniq!
      super(roles.join(" "))
    end

    # Returns true if the user has the given role.
    def has_alchemy_role?(role)
      alchemy_roles.include?(role.to_s)
    end

    def human_alchemy_roles
      alchemy_roles.map do |role|
        self.class.human_alchemy_rolename(role)
      end.to_sentence
    end

    # Calls unlock on all locked pages
    def unlock_pages!
      locked_pages.each(&:unlock!)
    end
  end
end
