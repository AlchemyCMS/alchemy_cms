class EssenceText < ActiveRecord::Base

  acts_as_essence
  
  # Require acts_as_ferret only if Ferret full text search is enabled (default).
  # You can disable it in +config/alchemy/config.yml+
  if Alchemy::Config.get(:ferret) == true
    require 'acts_as_ferret'
    acts_as_ferret(
      :fields => {
        :body => {:store => :yes}
      },
      :remote => false
    )
    before_save :check_ferret_indexing
  end

  # Saves the content from params
  def save_ingredient(params, options = {})
    return true if params.blank?
    self.body = params["body"]
    self.link = params["link"]
    self.link_title = params["link_title"]
    self.link_class_name = params["link_class_name"]
    self.link_target = params["link_target"]
    self.public = options[:public]
    self.save
  end

private

  def check_ferret_indexing
    if self.do_not_index
      self.disable_ferret(:always)
    end
  end

end
