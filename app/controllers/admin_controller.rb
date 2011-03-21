class AdminController < AlchemyController
  
  filter_access_to :index
  before_filter :set_translation
  before_filter :check_user_count, :only => :login
  
  layout 'alchemy'
  
  def index
    @alchemy_version = Alchemy.version
    @clipboard_items = session[:clipboard]
    @last_edited_pages = Page.all_last_edited_from(current_user)
    @locked_pages = Page.all_locked
    @online_users = User.all_online(current_user)
  end
  
  # Signup only works if no user is present in database.
  def signup
    if request.get?
      redirect_to admin_path if User.count != 0
      @user = User.new({:role => 'admin'})
    else
      @user = User.new(params[:user])
      if @user.save
        if params[:send_credentials]
          Mailer.deliver_new_alchemy_user_mail(@user, request)
        end
        redirect_to :action => :index
      end
    end
  end
  
  def login
    if request.get?
      @user_session = UserSession.new()
      flash.now[:info] = params[:message] || _("welcome_please_identify_notice")
      render :layout => 'login'
    else
      @user_session = UserSession.new(params[:user_session])
      if @user_session.save
        if session[:redirect_url].blank?
          redirect_to :action => :index
        else
          redirect_to session[:redirect_url]
        end
      else
        render :layout => 'login'
      end
    end
  end
  
  def logout
    message = params[:message] || _("logged_out")
    @user_session = UserSession.find
    if @user_session
      @user_session.destroy
    end
    flash[:info] = message
    redirect_to root_url
  end
  
private
  
  def check_user_count
    if User.count == 0
      redirect_to :action => 'signup'
    else
      return true
    end
  end
  
end
