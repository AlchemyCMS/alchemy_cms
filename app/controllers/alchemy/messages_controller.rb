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
  #     ingredients:
  #       - role: mail_to
  #         type: Text
  #       - role: subject
  #         type: Text
  #       - role: mail_from
  #         type: Text
  #       - role: success_page
  #         type: Page
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
  # Disabling the page caching is strongly recommended!
  #
  # Please have a look at the +alchemy/config/config.yml+ file for further Message settings.
  #
  class MessagesController < Alchemy::BaseController
    before_action :get_page, except: :create

    helper "alchemy/pages"

    def index # :nodoc:
      redirect_to show_page_path(
        urlname: @page.urlname,
        locale: prefix_locale? ? @page.language_code : nil
      )
    end

    def new # :nodoc:
      @message = Message.new
      render template: "alchemy/pages/show"
    end

    def create # :nodoc:
      @message = Message.new(message_params)
      @message.ip = request.remote_ip
      @element = Element.find_by(id: @message.contact_form_id)
      if @element.nil?
        raise ActiveRecord::RecordNotFound, "Contact form id not found. Please pass the :contact_form_id in a hidden field. Example: <%= f.hidden_field :contact_form_id, value: element.id %>"
      end

      @page = @element.page
      if @message.valid?
        MessagesMailer.contact_form_mail(@message, mail_to, mail_from, subject).deliver
        redirect_to_success_page
      else
        Current.page = @page
        render template: "alchemy/pages/show"
      end
    end

    private

    def mailer_config
      Alchemy.config.mailer
    end

    def mail_to
      @element.value_for(:mail_to) || mailer_config["mail_to"]
    end

    def mail_from
      @element.value_for(:mail_from) || mailer_config["mail_from"]
    end

    def subject
      @element.value_for(:subject) || mailer_config["subject"]
    end

    def redirect_to_success_page
      flash[:notice] = Alchemy.t(:success, scope: "contactform.messages")
      urlname = if success_page
        success_page_urlname
      elsif mailer_config["forward_to_page"] && mailer_config["mail_success_page"]
        Page.find_by(urlname: mailer_config["mail_success_page"]).urlname
      else
        Language.current_root_page.urlname
      end
      redirect_to alchemy.show_page_path(
        urlname: urlname,
        locale: prefix_locale? ? Current.language.code : nil
      )
    end

    def success_page
      @_success_page ||= @element.value_for(:success_page)
    end

    def success_page_urlname
      case success_page
      when Alchemy::Page
        success_page.urlname
      when String
        success_page
      end
    end

    def get_page
      @page = Current.language.pages.find_by(page_layout: mailer_config["page_layout_name"])
      if @page.blank?
        raise "Page for page_layout #{mailer_config["page_layout_name"]} not found"
      end
    end

    def message_params
      params.require(:message).permit(*mailer_config["fields"], :contact_form_id)
    end
  end
end
