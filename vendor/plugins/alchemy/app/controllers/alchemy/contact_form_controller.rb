class Alchemy::ContactFormController < ApplicationController
  
  @@validate_fields = ["vorname", "nachname", "email"]
  @@mail_to = "mailtest@macabi.de"
  @@mail_from = "kontakt@macabi.de"
  @@subject = "Eine Anfrage"
  @@content_type = "text/plain"

  def submit_data
    unless session[:mail_data].nil?
      session[:mail_data] = session[:mail_data].merge( params[:mail_data])
    else
      session[:mail_data] = params[:mail_data]
    end
    if check_data
      session[:mail_data][:ip] = request.remote_ip
      unless params[:mail_data][:contact_form_id].blank?
        contact_form_molecule = Molecule.find(params[:mail_data][:contact_form_id].to_i)
        unless contact_form_molecule.nil?
          mail_to = contact_form_molecule.atom_by_name("mail_to").atom.content
          mail_from = contact_form_molecule.atom_by_name("mail_from").atom.content
          subject = contact_form_molecule.atom_by_name("subject").atom.content
        end
      end
      mail_to = @@mail_to if mail_to.blank?
      mail_from = @@mail_from if mail_from.blank?
      subject = @@subject if subject.blank?
      Mailer.deliver_mail(
        session[:mail_data],
        mail_to,
        mail_from,
        subject,
        @@content_type
      )
      session[:mail_data] = nil
      if !params[:mail_data][:redirect_to].blank?
        redirect_to :controller => 'pages', :action => 'show', :urlname => params[:mail_data][:redirect_to]
      elsif(configuration(:mailer)[:forward_to_page])
        redirect_to :controller => 'pages', :action => 'show', :urlname => configuration(:mailer)[:mail_sucess_page]
      else
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.root.urlname
      end
    else
      redirect_to :back
    end
  end
  
  def check_data
    flash[:mail_errors] = Array.new
    flash[:mail_errors] << "<div class=\"mail_error_message\"'>Folgende Felder wurden nicht ausgefüllt:</div>\n"
    flash[:mail_errors] << "<ol class='mail_errors'>\n"
    if session[:mail_data].is_a?(Hash)
      session[:mail_data].each do |key, value|
        if @@validate_fields.include?(key) || @@validate_fields.empty?
          flash[:mail_errors] << "<li>#{key.camelize}</li>\n" if value.empty?
        end
      end
    else
      return false
    end
    flash[:mail_errors] << "</ol>"
    if !(flash[:mail_errors].length > 3)
      flash[:mail_errors] = []
    end
    return (flash[:mail_errors] == [])
  end
  
  def cancel
    session[:mail_data] = nil
    redirect_to :back
  end

end
