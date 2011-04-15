# == Sending Mails:
# To send Mails via contact forms you can create your form fields in the config.yml
# === Example:
# Make an Element with this options inside your elements.yml file:
#
#   - name: contact
#     display_name: Kontaktformular
#     contents:
#     - name: mail_to
#       type: EssenceText
#     - name: subject
#       type: EssenceText
#     - name: mail_from
#       type: EssenceText
#     - name: success_page
#       type: EssenceText
#
# The fields mail_to, mail_from, subject and success_page are recommended.
# The MailsController uses them to send your mails. So your customer has full controll of these values inside his contactform element.
# 
# Then make a page layout for your contact page in the page_layouts.yml file:
# 
#   - name: contact
#     display_name: Kontakt
#     unique: true
#     cache: false
#     elements: [pageheading, heading, contact, bild, absatz, file_download]
#     autogenerate: [contact]
#
# Disabling the page caching is stronlgy recommended!
#
# The editor view for your element should have this layout:
# 
#   <%= render_essence_editor_by_name(element, 'mail_from') %>
#   <%= render_essence_editor_by_name(element, 'mail_to') %>
#   <%= render_essence_editor_by_name(element, 'subject') %>
#   <p>
#     Folgeseite: <%= page_selector(element, 'success_page') %>
#   </p>
# 
# Please have a look at the vendor/plugins/alchemy/config/config.yml file for further Mail settings.

class MailsController < AlchemyController
  
  helper :pages
  
  def new#:nodoc:
    @mail = Mail.new
    @page = Page.find_by_page_layout(configuration(:mailer)[:page_layout_name])
    @root_page = Page.language_root_for(session[:language_id])
    raise "Page for page_layout #{configuration(:mailer)[:page_layout_name]} not found" if @page.blank?
    render :template => '/pages/show', :layout => 'pages'
  end
  
  def index#:nodoc:
    @page = Page.find_by_page_layout(configuration(:mailer)[:page_layout_name])
    raise "Page for page_layout #{configuration(:mailer)[:page_layout_name]} not found" if @page.blank?
    redirect_to send("show_page#{multi_language? ? '_with_language' : '' }_path", :urlname => @page.urlname, :lang => multi_language? ? @page.language_code : nil)
  end
  
  def create#:nodoc:
    @mail = Mail.new(params[:mail])
    @mail.ip = request.remote_ip
    element = Element.find_by_id(@mail.contact_form_id)
    @page = element.page
    @root_page = @page.get_language_root
    if @mail.save
      if params[:mail_to].blank?
        mail_to = element.ingredient("mail_to")
      else
        mail_to = configuration(:mailer)[:mail_addresses].detect{ |c| c[0] == params[:mail_to] }[1]
      end
      mail_from = element.ingredient("mail_from") rescue configuration(:mailer)[:mail_from]
      subject = element.ingredient("subject") rescue configuration(:mailer)[:subject]
      
      Mailer.deliver_mail(@mail, mail_to, mail_from, subject)
      
      if element.ingredient("success_page")
        if multi_language?
          language = Language.find(session[:language_id])
          redirect_to show_page_with_language_url(:urlname => element.ingredient("success_page"), :lang => language.code)
        else
          redirect_to show_page_url(:urlname => element.ingredient("success_page"))
        end
      elsif configuration(:mailer)[:forward_to_page] && configuration(:mailer)[:mail_success_page]
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.find_by_urlname(configuration(:mailer)[:mail_success_page]).urlname
      else
        flash[:notice] = I18n.t('alchemy.contactform.messages.success')
        redirect_to :controller => 'pages', :action => 'show', :urlname => Page.language_root_for(session[:language_id]).urlname
      end
    else
      render :template => '/pages/show', :layout => 'pages'
    end
  end
  
end
