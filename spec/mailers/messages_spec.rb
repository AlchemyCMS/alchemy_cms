require 'spec_helper'

module Alchemy
  describe Messages do

    let(:message) { Message.new(email: 'jon@doe.com', message: 'Lorem ipsum') }
    let(:mail) { Messages.contact_form_mail(message, 'admin@page.com', 'contact@page.com', 'Subject') }

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
