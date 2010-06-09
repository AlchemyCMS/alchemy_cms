class WaMail < ActiveRecord::Base
  tableless :columns => [
    [:contact_form_id, :integer],
    [:ip, :string]
  ] + Configuration.parameter(:mailer)[:fields]
  
  validate_fields = Configuration.parameter(:mailer)[:validate_fields]
  validate_fields.each do |field|
    validates_presence_of field[0], :message => field[1][:message]
    if field[0].to_s.include?('email')
      validates_format_of field[0], :with => Authlogic::Regex.email
    end
  end
  
end
