class WaMailsController < ApplicationController
  
  def new
    @wa_mail = WaMail.new
    @page = Page.find_by_page_layout(Configuration.parameter(:mailer)[:form_layout_name])
    render :layout => 'pages'
  end
  
  def create
    @wa_mail = WaMail.new(params[:wa_mail])
    @wa_mail.ip = request.remote_ip
    element = Element.find_by_id(@wa_mail.contact_form_id)
    @page = element.page
    if @wa_mail.save
      if params[:mail_to].blank?
        mail_to = element.atom_by_name("mail_to").content
      else
        mail_to = Configuration.parameter(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = element.atom_by_name("mail_from").content
      subject = element.atom_by_name("subject").content
      WaMailer.deliver_mail(
        @wa_mail,
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
      elsif !element.atom_by_name("success_page").blank?
        redirect_to show_page_url(element.atom_by_name("success_page").content)
      else
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.language_root(session[:language]).urlname
      end
    else
      render :file => "app/views/page_layouts/_#{@page.page_layout.underscore}.html.erb", :layout => 'pages'
    end
  end
  
end
