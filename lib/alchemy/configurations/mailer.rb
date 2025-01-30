# frozen_string_literal: true

module Alchemy
  module Configurations
    class Mailer < Alchemy::Configuration
      option :page_layout_name, :string, default: "contact"
      option :forward_to_page, :boolean, default: false
      option :mail_success_page, :string, default: "thanks"
      option :mail_from, :string, default: "your.mail@your-domain.com"
      option :mail_to, :string, default: "your.mail@your-domain.com"
      option :subject, :string, default: "A new contact form message"
      option :fields, :string_list, default: %w[salutation firstname lastname address zip city phone email message]
      option :validate_fields, :string_list, default: %w[lastname email]
    end
  end
end
