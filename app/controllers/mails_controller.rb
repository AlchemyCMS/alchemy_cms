class MailsController < ApplicationController
  
  def new
    @mail = Mail.new
    @page = Page.find_by_page_layout(Alchemy::Configuration.parameter(:mailer)[:form_layout_name])
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
        mail_to = Alchemy::Configuration.parameter(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = element.content_by_name("mail_from").essence.body
      subject = element.content_by_name("subject").essence.body
      Mailer.deliver_mail(
        @mail,
        mail_to,
        mail_from,
        subject
      )
      if configuration(:mailer)[:forward_to_page]
        success_page = Page.find_by_page_layout_and_language(configuration(:mailer)[:success_page_layout], session[:language])
        redirect_to(
          :controller => 'pages',
          :action => 'show',
          :urlname => success_page.urlname,
          :lang => multi_language ? session[:language] : nil
        )
      elsif !element.content_by_name("success_page").blank?
        redirect_to show_page_url(element.content_by_name("success_page").essence.body)
      else
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.language_root(session[:language]).urlname
      end
    else
      render :file => "app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb", :layout => 'pages'
    end
  end
  
end
