# This is a tableless model only used for validating Contactform Fields.
# You can specify the fields for your contactform in the config/alchemy/config.yml file in the :mailer options
# 
# === Options:
# 
# - form_layout_name: A Alchemy::PageLayout name (String). Used to render the contactform on a page with this layout.
# 
# === Validating fields:
# 
# Pass the field name as symbol and a message_id (will be translated) to :validate_fields:
# 
# === Translating the validation messages:
# 
# Validationmessages will be send to +I18n.t+ method with the scope +"alchemy.contactform.validations.#{field[1][:message].to_s}"+.
# So a +name+ field with the validation message_id +blank_name+ will be available for translation in your locale files like:
# 
#   de:
#     contactform:
#       validations:
#         blank_name: 'Bitte geben Sie Ihren Namen an'
#   
# === Example Contactform Configuration:
# 
#   :mailer:
#     :form_layout_name: contact
#     :fields: [subject, name, email, message, info]
#     :validate_fields:
#       :name:
#         :message: blank_name
#       :email:
#         :message: blank_email

module Alchemy
	class Message

		@@config = Alchemy::Config.get(:mailer)
		
		extend ActiveModel::Naming
		include ActiveModel::Validations
		include ActiveModel::Conversion
		
		attr_accessor :contact_form_id, :ip
		@@config[:fields].each do |field|
			attr_accessor field.to_sym
		end
		
		@@config[:validate_fields].each do |field|
			validates_presence_of field[0], :message => '^' + I18n.t(field[1][:message].to_s, :scope => "alchemy.contactform.validations")
			if field[0].to_s.include?('email')
				validates_format_of field[0], :with => Authlogic::Regex.email, :message => '^' + I18n.t('alchemy.contactform.validations.wrong_email_format'), :if => :email_is_filled
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
