require File.expand_path("spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

describe GettextI18nRails do
  it "extends all classes with fast_gettext" do
    _('test')
  end

  it "sets up out backend" do
    I18n.backend.is_a?(GettextI18nRails::Backend).should be_true
  end

  describe 'FastGettext I18n interaction' do
    before do
      FastGettext.available_locales = nil
      FastGettext.locale = 'de'
    end

    it "links FastGettext with I18n locale" do
      FastGettext.locale = 'xx'
      I18n.locale.should == :xx
    end

    it "does not set an not-accepted locale to I18n.locale" do
      FastGettext.available_locales = ['de']
      FastGettext.locale = 'xx'
      I18n.locale.should == :de
    end

    it "links I18n.locale and FastGettext.locale" do
      I18n.locale = :yy
      FastGettext.locale.should == 'yy'
    end

    it "does not set a non-available locale thorugh I18n.locale" do
      FastGettext.available_locales = ['de']
      I18n.locale = :xx
      FastGettext.locale.should == 'de'
      I18n.locale.should == :de
    end
  end
end