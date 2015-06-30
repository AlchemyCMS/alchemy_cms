module Alchemy
  module SoftDeleteable
    # DeleteNotSupport is raised when delete is called instead of soft_delete
    #
    DeleteNotSupported = Class.new(StandardError)

    def self.included(soft_deleteable)
      soft_deleteable.class_eval do
        scope :not_deleted, -> { where(deleted_at: nil) }
        alias_method :destroy_without_soft_delete, :destroy
      end
    end

    # Sets the deleted_at timestamp to indicate a soft delete
    #
    def soft_delete
      if persisted?
        self.deleted_at = Time.now
        save(validate: false)
      else
        true
      end
    end

    def deleted?
      deleted_at.present?
    end

    def delete
      raise DeleteNotSupported
    end

    def destroy
      run_callbacks(:destroy) { soft_delete }
    end
  end
end
