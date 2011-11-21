class Admin::LanguagesController < Admin::ResourcesController

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
	end

end
