class MailsController < AlchemyController
  
  helper :pages
  
  def new
    @mail = Mail.new
    @page = Page.find_by_page_layout(Alchemy::Configuration.parameter(:mailer)[:form_layout_name])
    render :template => '/pages/show', :layout => 'pages'
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
        mail_to = Alchemy::Configuration.parameter(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = element.content_by_name("mail_from").essence.body rescue Alchemy::Configuration.parameter(:mailer)[:mail_from]
      subject = element.content_by_name("subject").essence.body rescue Alchemy::Configuration.parameter(:mailer)[:subject]
      
      Mailer.deliver_mail(@mail, mail_to, mail_from, subject)
      
      if !element.content_by_name("success_page").essence.body.blank?
        if multi_language?
          language = Language.find(session[:language_id])
          redirect_to show_page_with_language_url(:urlname => element.content_by_name("success_page").essence.body, :lang => language.code)
        else
          redirect_to show_page_url(:urlname => element.content_by_name("success_page").essence.body)
        end
      else
        flash[:notice] = I18n.t('contactform.messages.success')
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.find_language_root_for(session[:language_id]).urlname
      end
    else
      render :template => '/pages/show', :layout => 'pages'
    end
    
  end
  
end
