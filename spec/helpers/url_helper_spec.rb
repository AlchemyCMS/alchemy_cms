require 'spec_helper'

include Alchemy::BaseHelper

module Alchemy
  describe UrlHelper do

    before do
      @page = mock_model(Page, :urlname => 'testpage', :language_code => 'en')
    end

    describe "#show_page_path_params" do

      context "when multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(true)
        end

        it "should return a Hash with urlname and language_id parameter" do
          helper.stub!(:multi_language?).and_return(true)
          helper.show_page_path_params(@page).should include(:urlname => 'testpage', :lang => 'en')
        end

        it "should return a Hash with urlname, language_id and query parameter" do
          helper.stub!(:multi_language?).and_return(true)
          helper.show_page_path_params(@page, {:query => 'test'}).should include(:urlname => 'testpage', :lang => 'en', :query => 'test')
        end

      end

      context "not multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(false)
        end

        it "should return a Hash with the urlname but without language_id parameter" do
          helper.show_page_path_params(@page).should include(:urlname => 'testpage')
          helper.show_page_path_params(@page).should_not include(:lang => 'en')
        end

        it "should return a Hash with urlname and query parameter" do
          helper.show_page_path_params(@page, {:query => 'test'}).should include(:urlname => 'testpage', :query => 'test')
          helper.show_page_path_params(@page).should_not include(:lang => 'en')
        end

      end

    end

    describe "#show_alchemy_page_path" do

      context "when multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(true)
        end

        it "should return the correct relative path string" do
          helper.show_alchemy_page_path(@page).should == "/alchemy/#{@page.language_code}/testpage"
        end

        it "should return the correct relative path string with additional parameters" do
          helper.show_alchemy_page_path(@page, {:query => 'test'}).should == "/alchemy/#{@page.language_code}/testpage?query=test"
        end

      end

      context "not multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(false)
        end

        it "should return the correct relative path string" do
          helper.show_alchemy_page_path(@page).should == "/alchemy/testpage"
        end

        it "should return the correct relative path string with additional parameter" do
          helper.show_alchemy_page_path(@page, {:query => 'test'}).should == "/alchemy/testpage?query=test"
        end

      end

    end

    describe "#show_alchemy_page_url" do

      context "when multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(true)
        end

        it "should return the correct url string" do
          helper.show_alchemy_page_url(@page).should == "http://#{helper.request.host}/alchemy/#{@page.language_code}/testpage"
        end

        it "should return the correct url string with additional parameters" do
          helper.show_alchemy_page_url(@page, {:query => 'test'}).should == "http://#{helper.request.host}/alchemy/#{@page.language_code}/testpage?query=test"
        end

      end

      context "not multi_language" do

        before do
          helper.stub!(:multi_language?).and_return(false)
        end

        it "should return the correct url string" do
          helper.show_alchemy_page_url(@page).should == "http://#{helper.request.host}/alchemy/testpage"
        end

        it "should return the correct url string with additional parameter" do
          helper.show_alchemy_page_url(@page, {:query => 'test'}).should == "http://#{helper.request.host}/alchemy/testpage?query=test"
        end

      end

    end

    describe 'picture path helpers' do

      let(:picture) { stub_model(Picture, :urlname => 'cute_kitten', :id => 42) }

      describe '#show_alchemy_picture_path' do

        it "should return the correct relative path string" do
          helper.show_alchemy_picture_path(picture).should =~ Regexp.new("/alchemy/pictures/42/show/cute_kitten.jpg")
        end

      end

      describe '#show_alchemy_picture_url' do

        it "should return the correct url string" do
          helper.show_alchemy_picture_url(picture).should =~ Regexp.new("http://#{helper.request.host}/alchemy/pictures/42/show/cute_kitten.jpg")
        end

      end

      describe '#show_picture_path_params' do

        it "should return the correct params for rendering a picture" do
          helper.show_picture_path_params(picture).should include(:name => 'cute_kitten', :format => 'jpg')
        end

        it "should include the secure hash parameter" do
          helper.show_picture_path_params(picture).keys.should include(:sh)
          helper.show_picture_path_params(picture)[:sh].should_not be_empty
        end

        context "with additional params" do

          it "should include these params" do
            helper.show_picture_path_params(picture, {:format => 'png'}).should include(:name => 'cute_kitten', :format => 'png')
          end

        end

        context "with additional params crop set to true" do

          it "should include crop as parameter" do
            helper.show_picture_path_params(picture, {:crop => true}).should include(:name => 'cute_kitten', :crop => 'crop')
          end

        end

      end

    end

  end
end
