require 'spec_helper'

module Alchemy
  describe MessagesController do

    before do
      controller.instance_variable_set(:@page, page)
      controller.stub!(:get_page).and_return(page)
    end

    describe "#index" do

      let(:page) { mock_model('Page', {urlname: 'contact', page_layout: 'contact'}) }

      it "should redirect to @page" do
        expect(get :index).to redirect_to(show_page_path(urlname: page.urlname))
      end
    end
    
    describe "#new" do      

      it "should render the alchemy/pages/show template" do
        get :new
        expect(get :new).to render_template('alchemy/pages/show')
      end

      it "should call #layout_for_page to render the correct layout" do
        controller.should_receive(:layout_for_page)
        get :new
      end
    end
    
    describe "#create" do

      before { controller.stub!(:params).and_return({message: {email: ''}}) }

      let(:page) { mock_model('Page', get_language_root: mock_model('Page')) }
      let(:element) { mock_model('Element', page: page, ingredient: '') }

      it "should raise ActiveRecord::RecordNotFound if element of contactform could not be found" do
        expect { get :create }.to raise_error(ActiveRecord::RecordNotFound)
      end

      context "if validation of message" do

        before do
          Element.stub!(:find_by_id).and_return(element)
          Message.any_instance.stub(:contact_form_id).and_return(1)
        end

        context "is false" do
          before { Message.any_instance.stub(:valid?).and_return(false) }

          it "should render 'alchemy/pages/show' template" do
            expect(get :create).to render_template('alchemy/pages/show')
          end
        end

        context "is true" do
          before do 
            Message.any_instance.stub(:valid?).and_return(true)
            Messages.stub_chain(:contact_form_mail, :deliver).and_return(true)
          end

          it "Messages should call Messages#contact_form_mail to send the email" do
            Messages.should_receive(:contact_form_mail)
            get :create
          end

          describe "#redirect_to_success_page" do

            context "if 'success_page' ingredient of element is set with urlname" do
              before { element.stub!(:ingredient).with('success_page').and_return('success-page') }

              it "should redirect to the given urlname" do
                expect(get :create).to redirect_to(show_page_path(urlname: 'success-page'))
              end
            end

            context "if 'success_page' ingredient of element is not set" do
              before { element.stub!(:ingredient).with('success_page').and_return(nil) }

              context "but mailer_config['forward_to_page'] is true and mailer_config['mail_success_page'] is set" do
                before do
                  controller.stub!(:mailer_config).and_return({'forward_to_page' => true, 'mail_success_page' => 'mailer-config-success-page'})
                  Page.stub_chain(:find_by_urlname, :urlname).and_return('mailer-config-success-page')
                end

                it "redirect to the given success page" do
                  expect(get :create).to redirect_to(show_page_path(urlname: 'mailer-config-success-page'))
                end
              end

              context "and mailer_config has no instructions for success_page" do
                before do
                  controller.stub!(:mailer_config).and_return({})
                end

                it "should redirect to the language root page" do
                  Page.stub_chain(:language_root_for, :urlname).and_return('lang-root')
                  expect(get :create).to redirect_to(show_page_path(urlname: 'lang-root'))
                end
              end

            end

          end
        end

      end
      
    end

  end
end
