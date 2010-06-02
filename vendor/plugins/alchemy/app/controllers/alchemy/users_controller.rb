class Alchemy::UsersController < ApplicationController

  layout 'alchemy'
  
  filter_access_to [:edit, :update, :destroy], :attribute_check => true
  filter_access_to [:index, :new, :create], :attribute_check => false
  
  before_filter :set_translation
  
  def index
    if !params[:query].blank?
      @users = User.find(:all, :conditions => [
        "wa_users.login LIKE ? OR wa_users.email LIKE ? OR wa_users.firstname LIKE ? OR wa_users.lastname LIKE ?",
        "%#{params[:query]}%",
        "%#{params[:query]}%",
        "%#{params[:query]}%",
        "%#{params[:query]}%"
      ],
      :order => 'login')
    else
      @users = User.all
    end
  end

  def new
    @user = User.new
    render :layout => false
  end
  
  def create
    @user = User.new(params[:wa_user])
    if @user.save
      if @user.role == "registered"
        Mailer.deliver_new_user_mail(@user, request)
      else
        Mailer.deliver_new_alchemy_user_mail(@user, request)
      end
    end
    render_errors_or_redirect(
      @user,
      wa_users_path,
      ( _("User: '%{name}' created") % {:name => @user.name} )
    )
  end
    
  def edit
    # User is fetched via before filter from authentication plugin
    render :layout => false
  end
  
  def update
    # User is fetched via before filter from authentication plugin
    @user.update_attributes(params[:wa_user])
    render_errors_or_redirect(
      @user,
      wa_users_path,
      ( _("User: '%{name}' updated") % {:name => @user.name} )
    )
  end
  
  def destroy
    # User is fetched via before filter from authentication plugin
    name = @user.name
    if @user.destroy
      flash[:notice] = ( _("User: '%{name}' deleted") % {:name => name} )
    end
    render :update do |page|
      page.redirect_to wa_users_path
    end
  end
  
end
