# frozen_string_literal: true

require 'spec_helper'

def reload_mailer_class(class_name)
  Alchemy.send(:remove_const, class_name)
  load("app/mailers/alchemy/#{class_name.underscore}.rb")
end

module Alchemy
  describe MessagesMailer do
    let(:message) { Message.new(email: 'jon@doe.com', message: 'Lorem ipsum') }
    let(:mail) { MessagesMailer.contact_form_mail(message, 'admin@page.com', 'contact@page.com', 'Subject') }

    it "inherits from ActionMailer::Base" do
      expect(MessagesMailer < ActionMailer::Base).to eq(true)
    end

    context "with ApplicationMailer defined" do
      before do
        class ::ApplicationMailer; end
        reload_mailer_class("BaseMailer")
        reload_mailer_class("MessagesMailer")
      end

      it "inherits from ApplicationMailer" do
        expect(MessagesMailer < ApplicationMailer).to eq(true)
      end
    end

    it "delivers a mail to owner" do
      expect(mail.to).to eq(['admin@page.com'])
      expect(mail.subject).to eq('Subject')
    end

    it "reply_to should be set to senders email" do
      expect(mail.reply_to).to eq([message.email])
    end

    it "mail body includes message" do
      expect(mail.body).to match /#{message.message}/
    end
  end
end
