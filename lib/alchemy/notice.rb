module Alchemy::Notice
  
  # shows the flash_notice div via ajax and highlights it. it even works in rescue cases. you only have to pass an 'render :update' page object. so place it in a 'render :update do |page|' - block. pass :error-symbol as last parameter to display the flash_notice div as with class error
  def self.show(page, notice, error = false)
    self.show_notice(page, notice, error || :notice)
  end
  
private
  
  def self.show_notice(page, message, style = :notice)
    page << "jQuery('#flash_notices').append('#{render(:partial => 'admin/partials/flash', :locals => {:flash_type => style.to_s, :message => message})}')"
    page << "jQuery('#flash_notices').show()"
    page << "Alchemy.fadeNotices()"
  end
  
end
