class WaUsersController < ApplicationController

  layout 'alchemy'
  
  filter_access_to [:edit, :update, :destroy], :attribute_check => true
  filter_access_to [:index, :new, :create], :attribute_check => false
  
  before_filter :set_translation
  
  def index
    if !params[:query].blank?
      @wa_users = WaUser.find(:all, :conditions => [
        "wa_users.login LIKE ? OR wa_users.email LIKE ? OR wa_users.firstname LIKE ? OR wa_users.lastname LIKE ?",
        "%#{params[:query]}%",
        "%#{params[:query]}%",
        "%#{params[:query]}%",
        "%#{params[:query]}%"
      ],
      :order => 'login')
    else
      @wa_users = WaUser.all
    end
  end

  def new
    @wa_user = WaUser.new
    render :layout => false
  end
  
  def create
    @wa_user = WaUser.new(params[:wa_user])
    if @wa_user.save
      if @wa_user.role == "registered"
        WaMailer.deliver_new_user_mail(@wa_user, request)
      else
        WaMailer.deliver_new_alchemy_user_mail(@wa_user, request)
      end
    end
    render_errors_or_redirect(
      @wa_user,
      wa_users_path,
      ( _("User: '%{name}' created") % {:name => @wa_user.name} )
    )
  end
    
  def edit
    # User is fetched via before filter from authentication plugin
    render :layout => false
  end
  
  def update
    # User is fetched via before filter from authentication plugin
    @wa_user.update_attributes(params[:wa_user])
    render_errors_or_redirect(
      @wa_user,
      wa_users_path,
      ( _("User: '%{name}' updated") % {:name => @wa_user.name} )
    )
  end
  
  def destroy
    # User is fetched via before filter from authentication plugin
    name = @wa_user.name
    if @wa_user.destroy
      flash[:notice] = ( _("User: '%{name}' deleted") % {:name => name} )
    end
    render :update do |page|
      page.redirect_to wa_users_path
    end
  end
  
end
