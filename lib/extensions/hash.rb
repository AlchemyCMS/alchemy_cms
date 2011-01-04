class Hash

  #this method adds an key/value pair in the pattern of :<name> => [] to the hash
  #only if the key <name> doesn't already exists. this function is provided
  #due to  http post's lack of providing the checkboxes field when no cb is
  #selected. I'm pretty sure that this could be moved direcly into the model
  #or even ActiveRecord.
  def add_key_for_checkboxes name
    self[name.to_s] = [] if self.stringify_keys[name.to_s].nil?
  end

end
