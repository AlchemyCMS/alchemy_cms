class ContentsController < ApplicationController
  before_filter :find_content, :only => [ :show, :edit, :update, :destroy ]

  def index 
    @contents = Content.paginate :page => params[:page]
  end

  def show
  end

  def new
    @content = Content.new
  end

  def create
    @content = Content.new(params[:content])
    if @content.save
      flash[:notice] = 'Content was successfully created.'
      redirect_to contents_url
    else
      render :action => 'new'
    end
    logger.error "#############{@content.errors.full_messages}"
  end

  def edit
  end

  def update
    if @content.update_attributes(params[:content])
      flash[:notice] = 'Content was successfully updated.'
      redirect_to :action => 'show', :id => @content
    else
      render :action => 'edit'
    end
  end

  def destroy
    @content.destroy
    redirect_to :action => 'list'
  end

  protected

    def find_content
      @content = Content.find params[:id]
    end

end
