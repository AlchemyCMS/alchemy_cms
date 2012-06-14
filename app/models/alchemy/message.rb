# This is a tableless model only used for validating contactform fields.
#
# You can specify the fields for your contactform in the +config/alchemy/config.yml+ file in the +:mailer+ options.
#
# === Example Contactform Configuration:
#
#   mailer:
#     form_layout_name: contact
#     fields: [subject, name, email, message, info]
#     validate_fields: [name, email]

module Alchemy
  class Message

    @@config = Config.get(:mailer)

    extend ::ActiveModel::Naming
    include ::ActiveModel::Validations
    include ::ActiveModel::Conversion
    include ::ActiveModel::MassAssignmentSecurity

    attr_accessor :contact_form_id, :ip
    attr_accessible :contact_form_id

    @@config['fields'].each do |field|
      attr_accessor field.to_sym
      attr_accessible field.to_sym
    end

    @@config['validate_fields'].each do |field|
      validates_presence_of field

      case field.to_sym
      when :email
        validates_format_of field, :with => ::Authlogic::Regex.email, :if => :email_is_filled
      when :email_confirmation
        validates_confirmation_of :email
      end
    end

    def initialize(attributes = {})
      attributes.keys.each do |a|
        send("#{a}=", attributes[a])
      end
    end

    def persisted? #:nodoc:
      false
    end

    private

    def email_is_filled #:nodoc:
      !email.blank?
    end

  end
end
