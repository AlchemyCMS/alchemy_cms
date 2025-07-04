# frozen_string_literal: true

require "rails_helper"

module Alchemy
  describe MessagesController do
    routes { Alchemy::Engine.routes }

    let(:page) { mock_model("Page") }

    before do
      controller.instance_variable_set(:@page, page)
      allow(controller).to receive(:get_page).and_return(page)
    end

    describe "#index" do
      let(:page) { mock_model("Page", {urlname: "contact", page_layout: "contact"}) }

      it "should redirect to @page" do
        expect(get(:index)).to redirect_to(show_page_path(urlname: page.urlname))
      end
    end

    describe "#new" do
      it "should render the alchemy/pages/show template" do
        get :new
        expect(get(:new)).to render_template("alchemy/pages/show")
      end
    end

    describe "#create" do
      subject do
        post :create, params: {message: {email: ""}}
      end

      let(:page) { mock_model("Page", get_language_root: mock_model("Page")) }
      let(:element) { mock_model("Element", page: page, ingredient: "") }
      let(:message) { Message.new }

      it "should raise ActiveRecord::RecordNotFound if element of contactform could not be found" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "if validation of message" do
        before do
          allow(Element).to receive(:find_by).and_return(element)
          allow(element).to receive(:value_for) { |a| (a == :success_page) ? "thank-you" : next }
          allow_any_instance_of(Message).to receive(:contact_form_id).and_return(1)
        end

        context "failed" do
          before do
            allow_any_instance_of(Message).to receive(:valid?).and_return(false)
          end

          it "should render 'alchemy/pages/show' template" do
            expect(subject).to render_template("alchemy/pages/show")
          end

          it "assigns Alchemy::Page.current" do
            expect(Alchemy::Current).to receive(:page=).with(page)
            subject
          end
        end

        context "succeeded" do
          before do
            allow_any_instance_of(Message).to receive(:valid?).and_return(true)
            allow(MessagesMailer).to receive(:contact_form_mail).and_return double(deliver: true)
          end

          it "Messages should call Messages#contact_form_mail to send the email" do
            expect(MessagesMailer).to receive(:contact_form_mail)
            subject
          end

          describe "#mail_to" do
            context "with element having mail_to ingredient" do
              before do
                allow(element).to receive(:value_for).with(:mail_to).and_return("peter@schroeder.de")
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the ingredient" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "peter@schroeder.de", "your.mail@your-domain.com", "A new contact form message"
                )
                subject
              end
            end

            context "with element having no mail_to ingredient" do
              before do
                allow(element).to receive(:value_for).with(:mail_to).and_return(nil)
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the config value" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "your.mail@your-domain.com", "your.mail@your-domain.com", "A new contact form message"
                )
                subject
              end
            end
          end

          describe "#mail_from" do
            context "with element having mail_from ingredient" do
              before do
                allow(element).to receive(:value_for).with(:mail_from).and_return("peter@schroeder.de")
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the ingredient" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "your.mail@your-domain.com", "peter@schroeder.de", "A new contact form message"
                )
                subject
              end
            end

            context "with element having no mail_from ingredient" do
              before do
                allow(element).to receive(:value_for).with(:mail_from).and_return(nil)
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the config value" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "your.mail@your-domain.com", "your.mail@your-domain.com", "A new contact form message"
                )
                subject
              end
            end
          end

          describe "#subject" do
            context "with element having subject ingredient" do
              before do
                allow(element).to receive(:value_for).with(:subject).and_return("A new message")
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the ingredient" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "your.mail@your-domain.com", "your.mail@your-domain.com", "A new message"
                )
                subject
              end
            end

            context "with element having no subject ingredient" do
              before do
                allow(element).to receive(:value_for).with(:subject).and_return(nil)
                message
                allow(Message).to receive(:new).and_return(message)
              end

              it "returns the config value" do
                expect(MessagesMailer).to receive(:contact_form_mail).with(
                  message, "your.mail@your-domain.com", "your.mail@your-domain.com", "A new contact form message"
                )
                subject
              end
            end
          end

          describe "#redirect_to_success_page" do
            context "if 'success_page' ingredient of element" do
              context "is set with urlname string" do
                before do
                  allow(element).to receive(:value_for).with(:success_page).and_return("success-page")
                end

                it "should redirect to the given urlname" do
                  expect(
                    subject
                  ).to redirect_to(show_page_path(urlname: "success-page"))
                end
              end

              context "is set with page instance" do
                let(:page) { build(:alchemy_page, name: "Success", urlname: "success-page") }

                before do
                  allow(element).to receive(:value_for).with(:success_page).and_return(page)
                end

                it "should redirect to the given urlname" do
                  expect(
                    subject
                  ).to redirect_to(show_page_path(urlname: "success-page"))
                end
              end
            end

            context "if 'success_page' ingredient of element is not set" do
              before do
                allow(element).to receive(:value_for).with(:success_page).and_return(nil)
              end

              context "but mailer_config['forward_to_page'] is true and mailer_config['mail_success_page'] is set" do
                before do
                  allow(controller).to receive(:mailer_config) do
                    {
                      "fields" => %w[email],
                      "forward_to_page" => true,
                      "mail_success_page" => "mailer-config-success-page"
                    }
                  end
                  allow(Page).to receive(:find_by).and_return double(urlname: "mailer-config-success-page")
                end

                it "redirect to the given success page" do
                  expect(
                    subject
                  ).to redirect_to(show_page_path(urlname: "mailer-config-success-page"))
                end
              end

              context "and mailer_config has no instructions for success_page" do
                let(:language) { mock_model("Language", code: "en", locale: "en", pages: double(find_by: build_stubbed(:alchemy_page))) }

                before do
                  allow(controller).to receive(:mailer_config).and_return({"fields" => %w[email]})
                  allow(Language).to receive(:current_root_page).and_return double(urlname: "lang-root")
                end

                it "should redirect to the language root page" do
                  allow(Current).to receive(:language).and_return(language)
                  expect(
                    subject
                  ).to redirect_to(show_page_path(urlname: "lang-root"))
                end
              end
            end
          end
        end
      end
    end

    describe "#message_params" do
      before do
        allow(controller).to receive(:params).and_return(ActionController::Parameters.new(message: {email: "email@addr.com", contact_form_id: "23"}).permit!)
      end

      context "when mailer_config['fields'] includes :contact_field_id" do
        before do
          allow(controller).to receive(:mailer_config).and_return({page_layout_name: "contact", forward_to_page: false, mail_success_page: "thanks", mail_from: "your.mail@your-domain.com", mail_to: "your.mail@your-domain.com", subject: "A new contact form message", fields: ["salutation", "firstname", "lastname", "address", "zip", "city", "phone", "email", "message", "contact_field_id"], validate_fields: ["lastname", "email"]})
        end

        it "should permit :contact_form_id" do
          expect(controller.send(:mailer_config)[:fields]).to include "contact_field_id"

          msg_params = subject.send(:message_params)

          expect(msg_params).to include :contact_form_id
        end
      end

      context "when mailer_config['fields'] does not inlcude :contact_field_id" do
        it "should permit :contact_form_id" do
          expect(Alchemy.config.mailer.fields).not_to include "contact_field_id"
          msg_params = subject.send(:message_params)

          expect(msg_params).to include :contact_form_id
        end
      end
    end
  end
end
