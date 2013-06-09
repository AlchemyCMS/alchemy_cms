require 'spec_helper'

module Alchemy
  describe Messages do

    let(:message) { Message.new(email: 'jon@doe.com', message: 'Lorem ipsum') }
    let(:mail) { Messages.contact_form_mail(message, 'admin@page.com', 'contact@page.com', 'Subject') }

    it "delivers a mail to owner" do
      mail.to.should == ['admin@page.com']
      mail.subject.should == 'Subject'
    end

    it "reply_to should be set to senders email" do
      mail.reply_to.should == [message.email]
    end

    it "mail body includes message" do
      mail.body.should match /#{message.message}/
    end

  end
end
