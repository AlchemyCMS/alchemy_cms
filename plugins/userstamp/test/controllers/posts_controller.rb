class PostsController < UserstampController
  def edit
    @post = Post.find(params[:id])
    render(:inline  => "<%= @post.title %>")
  end
  
  def update
    @post = Post.find(params[:id])
    @post.update_attributes(params[:post])
    render(:inline => "<%= @post.title %>")
  end

  protected
    def current_user
      Person.find(session[:person_id])
    end
    
    def set_stamper
      Person.stamper = self.current_user
    end

    def reset_stamper
      Person.reset_stamper
    end    
  #end
end