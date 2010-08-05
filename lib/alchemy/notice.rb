module Alchemy::Notice
  
  FLASH_NOTICE_STARTCOLOR = "#FFFFFF"
  FLASH_NOTICE_ENDCOLOR = "#E2EFD3"
  FLASH_ERROR_STARTCOLOR = "#FFFFFF"
  FLASH_ERROR_ENDCOLOR = "#EFD3D3"
  
  # shows the flash_notice div via ajax and highlights it. it even works in rescue cases. you only have to pass an 'render :update' page object. so place it in a 'render :update do |page|' - block. pass :error-symbol as last parameter to display the flash_notice div as with class error
  def self.show_via_ajax(page, notice, error = false)
    self.show_notice(page, notice, error || :notice)
  end
  
private
  
  def self.show_notice(page, message, style = :notice)
    flash = {}
    flash[style.to_sym] = message
    page.replace("flash_notices", :partial => "admin/partials/flash_notice", :locals => {:flash => flash})
    page.show("flash_notices")
    page << %(
new Effect.Highlight(
  $$('#flash_notices div.#{style.to_s}')[0], {
    duration: 0.3,
    startcolor: '#{style == :notice ? FLASH_NOTICE_STARTCOLOR : FLASH_ERROR_STARTCOLOR}',
    endcolor: '#{style == :notice ? FLASH_NOTICE_ENDCOLOR : FLASH_ERROR_ENDCOLOR}'
  }
);
    )
  end
  
end
