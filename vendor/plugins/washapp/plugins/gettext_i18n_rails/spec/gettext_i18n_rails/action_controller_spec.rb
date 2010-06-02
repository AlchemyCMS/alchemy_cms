require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

describe ActionController::Base do
  before do
    #controller
    @c = ActionController::Base.new
    @c.params = @c.session = {}
    @c.request = stub(:env=>{},:cookies=>{})

    #locale
    FastGettext.available_locales = nil
    FastGettext.locale = 'fr'
    FastGettext.available_locales = ['fr','en']
  end

  it "changes the locale" do
    @c.params = {:locale=>'en'}
    @c.set_gettext_locale
    @c.session[:locale].should == 'en'
    FastGettext.locale.should == 'en'
  end

  it "stays with default locale when none was found" do
    @c.set_gettext_locale
    @c.session[:locale].should == 'fr'
    FastGettext.locale.should == 'fr'
  end

  it "reads the locale from the HTTP_ACCEPT_LANGUAGE" do
    @c.request.stubs(:env).returns 'HTTP_ACCEPT_LANGUAGE'=>'de-de,de;q=0.8,en-us;q=0.5,en;q=0.3'
    @c.set_gettext_locale
    FastGettext.locale.should == 'en'
  end
end