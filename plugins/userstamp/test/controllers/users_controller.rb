class UsersController < UserstampController
  def edit
    @user = User.find(params[:id])
    render(:inline  => "<%= @user.name %>")
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(params[:user])
    render(:inline => "<%= @user.name %>")
  end
end