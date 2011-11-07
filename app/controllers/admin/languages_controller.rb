class Admin::LanguagesController < AlchemyController
  
  filter_resource_access
  before_filter :set_translation
  
  def index
    if !params[:query].blank?
      @languages = Language.where([
        "languages.name LIKE ? OR languages.code = ? OR languages.frontpage_name LIKE ?",
        "%#{params[:query]}%",
        "#{params[:query]}",
        "%#{params[:query]}%"
      ])
    else
      @languages = Language.all
    end
  end

  def new
    @language = Language.new
    render :layout => false
  end

  def edit
    render :layout => false
  end

  def create
    @language = Language.new(params[:language])
    @language.save
    render_errors_or_redirect(
      @language,
      admin_languages_path,
      ( _("Language '%{name}' created") % {:name => @language.name} ),
      "form#new_language button.button"
    )
  end

  def update
    @language.update_attributes(params[:language])
    render_errors_or_redirect(
      @language,
      admin_languages_path,
      ( _("Language '%{name}' updated") % {:name => @language.name} ),
      "form#edit_language_#{@language.id} button.button"
    )
  end

  def destroy
    name = @language.name
		@language.destroy
		flash[:notice] = ( _("Language '%{name}' destroyed") % {:name => name} )
		set_language_to_default
  rescue Exception => e
		exception_handler(e)
  end

private

  def find_language
    @language = Language.find(params[:id])
  end

end
