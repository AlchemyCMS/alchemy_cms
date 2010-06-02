class WaMailsController < ApplicationController
  
  def new
    @wa_mail = WaMail.new
    @wa_page = WaPage.find_by_page_layout(WaConfigure.parameter(:mailer)[:form_layout_name])
    render :layout => 'wa_pages'
  end
  
  def create
    @wa_mail = WaMail.new(params[:wa_mail])
    @wa_mail.ip = request.remote_ip
    wa_molecule = WaMolecule.find_by_id(@wa_mail.contact_form_id)
    @wa_page = wa_molecule.wa_page
    if @wa_mail.save
      if params[:mail_to].blank?
        mail_to = wa_molecule.atom_by_name("mail_to").content
      else
        mail_to = WaConfigure.parameter(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = wa_molecule.atom_by_name("mail_from").content
      subject = wa_molecule.atom_by_name("subject").content
      WaMailer.deliver_mail(
        @wa_mail,
        mail_to,
        mail_from,
        subject
      )
      if configuration(:mailer)[:forward_to_page]
        success_page = WaPage.find_by_page_layout_and_language(configuration(:mailer)[:success_page_layout], session[:language])
        redirect_to(
          :controller => 'wa_pages',
          :action => 'show',
          :urlname => success_page.urlname,
          :lang => multi_language ? session[:language] : nil
        )
      elsif !wa_molecule.atom_by_name("success_page").blank?
        redirect_to show_page_url(wa_molecule.atom_by_name("success_page").content)
      else
        redirect_to :controller => 'wa_pages', :action => 'show', :urlname => WaPage.language_root(session[:language]).urlname
      end
    else
      render :file => "app/views/page_layouts/_#{@wa_page.page_layout.underscore}.html.erb", :layout => 'wa_pages'
    end
  end
  
end
