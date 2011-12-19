class Admin::EssenceFilesController < AlchemyController

  filter_access_to :all
	helper :contents

  def edit
    @content = Content.find(params[:id])
    @essence_file = @content.essence
    render :layout => false
  end

  def update
    @essence_file = EssenceFile.find(params[:id])
    @essence_file.update_attributes(params[:essence_file])
    render :update do |page|
      page.call "Alchemy.closeCurrentWindow"
      page.call "Alchemy.reloadPreview"
    end
  end

  def assign
    @content = Content.find_by_id(params[:id])
    @attachment = Attachment.find_by_id(params[:attachment_id])
    @content.essence.attachment = @attachment
    @content.essence.save
    @content.save
    @options = params[:options]
    render :update do |page|
      page << "jQuery('##{@content.essence_type.underscore}_#{@content.id}').replaceWith('#{escape_javascript(render(:partial => "essences/essence_file_editor.html.erb", :locals => {:content => @content, :options => @options}))}')"
      page.call "Alchemy.closeCurrentWindow"
      page.call "Alchemy.reloadPreview"
      page.call "Alchemy.setElementDirty", "#element_#{@content.element.id}"
    end
  end

end
