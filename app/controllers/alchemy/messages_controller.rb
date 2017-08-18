# frozen_string_literal: true

module Alchemy
  #
  # == Sending Messages:
  #
  # To send Messages via contact forms you can create your form fields in the config.yml
  #
  # === Example:
  #
  # Make an Element with this options inside your @elements.yml file:
  #
  #   - name: contactform
  #     contents:
  #     - name: mail_to
  #       type: EssenceText
  #     - name: subject
  #       type: EssenceText
  #     - name: mail_from
  #       type: EssenceText
  #     - name: success_page
  #       type: EssenceSelect
  #
  # The fields +mail_to+, +mail_from+, +subject+ and +success_page+ are recommended.
  # The +Alchemy::MessagesController+ uses them to send your mails. So your customer has full controll of these values inside his contactform element.
  #
  # Then make a page layout for your contact page in the +page_layouts.yml+ file:
  #
  #   - name: contact
  #     unique: true
  #     cache: false
  #     elements: [pageheading, heading, contactform]
  #     autogenerate: [contactform]
  #
  # Disabling the page caching is stronlgy recommended!
  #
  # The editor view for your element should have this layout:
  #
  #   <%= render_essence_editor_by_name(element, 'mail_from') %>
  #   <%= render_essence_editor_by_name(element, 'mail_to') %>
  #   <%= render_essence_editor_by_name(element, 'subject') %>
  #   <%= page_selector(element, 'success_page', page_attribute: :urlname) %>
  #
  # Please have a look at the +alchemy/config/config.yml+ file for further Message settings.
  #
  class MessagesController < Alchemy::BaseController
    before_action :get_page, except: :create

    helper 'alchemy/pages'

    def index #:nodoc:
      redirect_to show_page_path(
        urlname: @page.urlname,
        locale: prefix_locale? ? @page.language_code : nil
      )
    end

    def new #:nodoc:
      @message = Message.new
      render template: 'alchemy/pages/show'
    end

    def create #:nodoc:
      @message = Message.new(message_params)
      @message.ip = request.remote_ip
      @element = Element.find_by(id: @message.contact_form_id)
      if @element.nil?
        raise ActiveRecord::RecordNotFound, "Contact form id not found. Please pass the :contact_form_id in a hidden field. Example: <%= f.hidden_field :contact_form_id, value: element.id %>"
      end
      @page = @element.page
      @root_page = @page.get_language_root
      if @message.valid?
        MessagesMailer.contact_form_mail(@message, mail_to, mail_from, subject).deliver
        redirect_to_success_page
      else
        render template: 'alchemy/pages/show'
      end
    end

    private

    def mailer_config
      Alchemy::Config.get(:mailer)
    end

    def mail_to
      @element.ingredient(:mail_to) || mailer_config['mail_to']
    end

    def mail_from
      @element.ingredient(:mail_from) || mailer_config['mail_from']
    end

    def subject
      @element.ingredient(:subject) || mailer_config['subject']
    end

    def redirect_to_success_page
      flash[:notice] = Alchemy.t(:success, scope: 'contactform.messages')
      if @element.ingredient(:success_page)
        urlname = @element.ingredient(:success_page)
      elsif mailer_config['forward_to_page'] && mailer_config['mail_success_page']
        urlname = Page.find_by(urlname: mailer_config['mail_success_page']).urlname
      else
        urlname = Language.current_root_page.urlname
      end
      redirect_to show_page_path(
        urlname: urlname,
        locale: prefix_locale? ? Language.current.code : nil
      )
    end

    def get_page
      @page = Language.current.pages.find_by(page_layout: mailer_config['page_layout_name'])
      if @page.blank?
        raise "Page for page_layout #{mailer_config['page_layout_name']} not found"
      end
      @root_page = @page.get_language_root
    end

    def message_params
      params.require(:message).permit(*mailer_config['fields'])
    end
  end
end
