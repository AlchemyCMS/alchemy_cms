class MailsController < AlchemyController
  
  helper :pages
  
  def new
    @mail = Mail.new
    @page = Page.find_by_page_layout(Alchemy::Config.get(:mailer)[:form_layout_name])
    render :layout => 'pages'
  end
  
  def create
    @mail = Mail.new(params[:mail])
    @mail.ip = request.remote_ip
    element = Element.find_by_id(@mail.contact_form_id)
    @page = element.page
    if @mail.save
      if params[:mail_to].blank?
        mail_to = element.content_by_name("mail_to").essence.body
      else
        mail_to = Alchemy::Config.get(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = element.content_by_name("mail_from").essence.body
      subject = element.content_by_name("subject").essence.body
      Mailer.deliver_mail(
        @mail,
        mail_to,
        mail_from,
        subject
      )
      if !element.content_by_name("success_page").essence.body.blank?
        if multi_language?
          redirect_to show_page_with_language_url(:urlname => element.content_by_name("success_page").essence.body, :lang => session[:language])
        else
          redirect_to show_page_url(:urlname => element.content_by_name("success_page").essence.body)
        end
      else
        flash[:notice] = I18n.t('contactform.messages.success')
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.language_root(session[:language]).urlname
      end
    else
      if File.exists?("app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb")
        render :file => "app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb", :layout => 'pages'
      elsif File.exists?("vendor/plugins/alchemy/app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb")
        render :file => "vendor/plugins/alchemy/app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb", :layout => 'pages'
      else
        render :file => "public/404.html", :status => 404
      end
    end
  end
  
end
