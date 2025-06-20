# frozen_string_literal: true

# This is a tableless model used for contact forms.
#
# You can specify the fields for your contact form in
# +config/alchemy/config.yml+ file as +:mailer+ +fields+.
#
# === Example Configuration:
#
#   mailer:
#     form_layout_name: contact
#     fields: [subject, name, email, message, info]
#     validate_fields: [name, email]
#
module Alchemy
  class Message
    include ActiveModel::Model

    def self.config
      Alchemy.config.mailer
    end

    attr_accessor :contact_form_id, :ip

    Alchemy.config.mailer.fields.each do |field|
      attr_accessor field.to_sym
    end

    Alchemy.config.mailer.validate_fields.each do |field|
      validates_presence_of field

      case field.to_sym
      when /email/
        validates_format_of field,
          with: Alchemy.config.format_matchers.email,
          if: -> { send(field).present? }
      when :email_confirmation
        validates_confirmation_of :email
      end
    end
  end
end
