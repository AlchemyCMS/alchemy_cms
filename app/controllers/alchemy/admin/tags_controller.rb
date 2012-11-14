module Alchemy
  module Admin
    class TagsController < BaseController

      before_filter :load_tag, :only => [:edit, :update, :destroy]

      def index
        @tags = ActsAsTaggableOn::Tag.where(
          "name LIKE '%#{params[:query]}%'"
        ).page(params[:page] || 1).per(per_page_value_for_screen_size).order("name ASC")
      end

      def new
        @tag = ActsAsTaggableOn::Tag.new
        render :layout => false
      end

      def create
        @tag = ActsAsTaggableOn::Tag.create(params[:tag])
        render_errors_or_redirect @tag, admin_tags_path, t('New Tag Created')
      end

      def edit
        @tags = ActsAsTaggableOn::Tag.order("name ASC").all - [@tag]
        render :layout => false
      end

      def update
        if params[:replace]
          @new_tag = ActsAsTaggableOn::Tag.find(params[:tag][:merge_to])
          Tag.replace(@tag, @new_tag)
          operation_text = t('Replaced Tag %{old_tag} with %{new_tag}') % {:old_tag => @tag.name, :new_tag => @new_tag.name}
          @tag.destroy
        else
          @tag.update_attributes(params[:tag])
          @tag.save
          operation_text = t(:successfully_updated_tag)
        end
        render_errors_or_redirect @tag, admin_tags_path, operation_text
      end

      def destroy
        if request.delete?
          @tag.destroy
          flash[:notice] = t(:successfully_deleted_tag)
        end
        @redirect_url = admin_tags_path
        render :action => :redirect
      end

      def autocomplete
        items = ActsAsTaggableOn::Tag.where(['LOWER(name) LIKE ?', "#{params[:term].downcase}%"])
        render :json => json_for_autocomplete(items, :name)
      end

    private

      def load_tag
        @tag = ActsAsTaggableOn::Tag.find(params[:id])
      end

    end
  end
end
