module Alchemy
  class EssenceText < ActiveRecord::Base

    acts_as_essence

    attr_accessible(
      :do_not_index,
      :body,
      :public,
      :link,
      :link_title,
      :link_class_name,
      :link_target
    )

    # Enable Ferret indexing.
    #
    # But only, if Ferret full text search is enabled (default).
    #
    # You can disable it in +config/alchemy/config.yml+
    #
    if Config.get(:ferret) == true
      require 'acts_as_ferret'
      acts_as_ferret(:fields => { :body => {:store => :yes} }, :remote => false)

      # Ensures that the current setting for do_not_index gets updated in the db.
      before_save { write_attribute(:do_not_index, description['do_not_index'] || false); return true }

      # Disables the ferret indexing, if do_not_index attribute is set to true
      #
      # You can disable indexing in the elements.yml file.
      #
      # === Example
      #
      #   name: contact_form
      #   contents:
      #   - name: email
      #     type: EssenceText
      #     do_not_index: true
      #
      def ferret_enabled?(is_bulk_index = false)
        !do_not_index?
      end
    end

  end
end
