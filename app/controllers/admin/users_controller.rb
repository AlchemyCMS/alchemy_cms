class Admin::UsersController < AlchemyController
  
  filter_access_to [:edit, :update, :destroy], :attribute_check => true
  filter_access_to [:index, :new, :create], :attribute_check => false
  
  before_filter :set_translation
  
  def index
    if !params[:query].blank?
      @users = User.find(:all, :conditions => [
        "users.login LIKE ? OR users.email LIKE ? OR users.firstname LIKE ? OR users.lastname LIKE ?",
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
    @user = User.new(params[:user])
    if @user.save
      if @user.role == "registered" && params[:send_credentials]
        Mailer.deliver_new_user_mail(@user, request)
      else
        Mailer.deliver_new_alchemy_user_mail(@user, request) if params[:send_credentials]
      end
    end
    render_errors_or_redirect(
      @user,
      admin_users_path,
      ( _("User: '%{name}' created") % {:name => @user.name} ),
      "form#new_user button.button"
    )
  rescue
    exception_handler($!)
  end
  
  def edit
    # User is fetched via before filter from authentication plugin
    render :layout => false
  end
  
  def update
    # User is fetched via before filter from authentication plugin
    @user.update_attributes(params[:user])
    Mailer.deliver_new_alchemy_user_mail(@user, request) if params[:send_credentials]
    render_errors_or_redirect(
      @user,
      admin_users_path,
      ( _("User: '%{name}' updated") % {:name => @user.name} ),
      "form#edit_user_#{@user.id} button.button"
    )
  end
  
  def destroy
    # User is fetched via before filter from authentication plugin
    name = @user.name
    if @user.destroy
      flash[:notice] = ( _("User: '%{name}' deleted") % {:name => name} )
    end
    render :update do |page|
      page.redirect_to admin_users_path
    end
  end
  
end
