require File.expand_path("../spec_helper", File.dirname(__FILE__))

describe GettextI18nRails::Backend do
  it "redirects calls to another I18n backend" do
    subject.backend.expects(:xxx).with(1,2)
    subject.xxx(1,2)
  end

  describe :available_locales do
    it "maps them to FastGettext" do
      FastGettext.expects(:available_locales).returns [:xxx]
      subject.available_locales.should == [:xxx]
    end

    it "returns an epmty array when FastGettext.available_locales is nil" do
      FastGettext.expects(:available_locales)
      subject.available_locales.should == []
    end
  end

  describe :translate do
    it "uses gettext when the key is translateable" do
      FastGettext.expects(:current_repository).returns 'xy.z.u'=>'a'
      subject.translate('xx','u',:scope=>['xy','z']).should == 'a'
    end

    it "can translate with gettext using symbols" do
      FastGettext.expects(:current_repository).returns 'xy.z.v'=>'a'
      subject.translate('xx',:v ,:scope=>['xy','z']).should == 'a'
    end

    it "can translate with gettext using a flat scope" do
      FastGettext.expects(:current_repository).returns 'xy.z.x'=>'a'
      subject.translate('xx',:x ,:scope=>'xy.z').should == 'a'
    end

    it "uses the super when the key is not translateable" do
      lambda{subject.translate('xx','y',:scope=>['xy','z'])}.should raise_error(I18n::MissingTranslationData)
    end
  end
end