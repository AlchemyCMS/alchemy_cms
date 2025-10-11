require "rails_helper"

RSpec.describe Alchemy do
  describe ".preview_sources" do
    subject { Alchemy.preview_sources }

    it "returns a Set of preview sources" do
      Alchemy::Deprecation.silence do
        is_expected.to be_a(Alchemy::Configuration::CollectionOption)
      end
    end
  end

  describe ".config" do
    subject { Alchemy.config }

    it "is a config object" do
      expect(subject).to be_a(Alchemy::Configurations::Main)
    end

    it "has the auto_logout_time from config.yml" do
      expect(subject.auto_logout_time).to eq(40)
    end

    it "has the output_image_quality from test.config.yml" do
      expect(subject.output_image_quality).to eq(85)
    end

    it "has the default image output format" do
      expect(subject.image_output_format).to eq("original")
    end

    describe "format matchers" do
      describe "email" do
        subject { Alchemy.config.format_matchers.email }

        it { is_expected.to match("hello@gmail.com") }
        it { is_expected.not_to match("stulli@gmx") }
      end

      describe "url" do
        subject { Alchemy.config.format_matchers.url }

        it { is_expected.to match("www.example.com:80/about") }
        it { is_expected.not_to match('www.example.com:80\/about') }
      end

      describe "link_url" do
        subject { Alchemy.config.format_matchers.link_url }

        it { is_expected.to match("tel:12345") }
        it { is_expected.to match("mailto:stulli@gmx.de") }
        it { is_expected.to match("/home") }
        it { is_expected.to match("https://example.com/home") }
        it { is_expected.not_to match('\/brehmstierleben') }
        it { is_expected.not_to match('https:\/\/example.com/home') }
      end
    end
  end

  describe "admin_importmaps" do
    subject { Alchemy.config.admin_importmaps }
    it "includes alchemy_admin importmap" do
      expect(subject.first.to_h).to eq({
        importmap_path: Alchemy::Engine.root.join("config/importmap.rb"),
        name: "alchemy_admin",
        source_paths: [
          Alchemy::Engine.root.join("app/javascript"),
          Alchemy::Engine.root.join("vendor/javascript")
        ]
      })
    end
  end

  describe ".configure" do
    subject do
      Alchemy.configure do |config|
        config.auto_logout_time = 500
      end
    end

    around do |example|
      old_auto_logout_time = Alchemy.config.auto_logout_time
      example.run
      Alchemy.config.auto_logout_time = old_auto_logout_time
    end

    it "yields the config object" do
      expect { subject }.to change(Alchemy.config, :auto_logout_time).to(500)
    end
  end

  describe "deprecated: Config" do
    subject { Alchemy::Config }

    it "is the same as Alchemy.config, but deprecated" do
      expect(Alchemy::Deprecation).to receive(:warn)
      expect(Alchemy::Config).to eq(Alchemy.config)
    end
  end

  describe "legacy configuration methods" do
    around do |example|
      Alchemy::Deprecation.silence { example.run }
    end
    describe ".enable_searchable" do
      it "forwards to config.page_searchable_checkbox" do
        expect do
          Alchemy.enable_searchable = true
        end.to change(Alchemy.config, :show_page_searchable_checkbox).to(true)
        # Reset
        expect do
          Alchemy.enable_searchable = false
        end.to change(Alchemy, :enable_searchable).to(false)
      end
    end

    describe ".user_class_primary_key" do
      subject { Alchemy.user_class_primary_key }

      it { is_expected.to eq(:id) }
    end

    describe ".user_class_primary_key=" do
      subject { Alchemy.user_class_primary_key = :uuid }

      around do |example|
        old_user_class_primary_key = Alchemy.config.user_class_primary_key
        example.run
        Alchemy.config.user_class_primary_key = old_user_class_primary_key
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.user_class_primary_key }.from(:id).to(:uuid)
      end
    end

    describe ".current_user_method" do
      subject { Alchemy.current_user_method }

      it { is_expected.to eq(:current_user) }
    end

    describe ".current_user_method=" do
      subject { Alchemy.current_user_method = :my_current_user }

      around do |example|
        real_current_user_method = Alchemy.config.current_user_method
        example.run
        Alchemy.config.current_user_method = real_current_user_method
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.current_user_method }.from(:current_user).to(:my_current_user)
      end
    end

    describe ".signup_path" do
      subject { Alchemy.signup_path }

      it { is_expected.to eq("/signup") }
    end

    describe ".signup_path=" do
      subject { Alchemy.signup_path = "/register" }

      around do |example|
        real_signup_path = Alchemy.config.signup_path
        example.run
        Alchemy.config.signup_path = real_signup_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.signup_path }.from("/signup").to("/register")
      end
    end

    describe ".login_path" do
      subject { Alchemy.login_path }

      it { is_expected.to eq("/login") }
    end

    describe ".login_path=" do
      subject { Alchemy.login_path = "/sign_in" }

      around do |example|
        real_login_path = Alchemy.config.login_path
        example.run
        Alchemy.config.login_path = real_login_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.login_path }.from("/login").to("/sign_in")
      end
    end

    describe ".logout_path" do
      subject { Alchemy.logout_path }

      it { is_expected.to eq("/logout") }
    end

    describe ".logout_path=" do
      subject { Alchemy.logout_path = "/leave" }

      around do |example|
        real_logout_path = Alchemy.config.logout_path
        example.run
        Alchemy.config.logout_path = real_logout_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.logout_path }.from("/logout").to("/leave")
      end
    end

    describe ".logout_method" do
      subject { Alchemy.logout_method }

      it { is_expected.to eq("delete") }
    end

    describe ".logout_method=" do
      subject { Alchemy.logout_method = "get" }

      around do |example|
        real_logout_method = Alchemy.config.logout_method
        example.run
        Alchemy.config.logout_method = real_logout_method
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.logout_method }.from("delete").to("get")
      end
    end

    describe ".unauthorized_path" do
      subject { Alchemy.unauthorized_path }

      it { is_expected.to eq("/") }
    end

    describe ".unauthorized_path=" do
      subject { Alchemy.unauthorized_path = "/nope" }

      around do |example|
        real_unauthorized_path = Alchemy.config.unauthorized_path
        example.run
        Alchemy.config.unauthorized_path = real_unauthorized_path
      end

      it "changes the main configuration" do
        expect { subject }.to change { Alchemy.config.unauthorized_path }.from("/").to("/nope")
      end
    end

    describe ".user_class" do
      subject { Alchemy.user_class }

      it "calls out to the main configuration" do
        expect(Alchemy.config).to receive(:user_class)
        subject
      end
    end

    describe ".user_class_name" do
      subject { Alchemy.user_class_name }

      it "calls out to the main configuration" do
        expect(Alchemy.config).to receive(:user_class_name)
        subject
      end
    end

    describe ".user_class_name=" do
      subject { Alchemy.user_class_name = "MyUserClass" }

      it "calls out to the main configuration" do
        expect(Alchemy.config).to receive(:user_class=).with("MyUserClass")
        subject
      end
    end

    describe ".register_ability" do
      let(:klass) { double }
      subject { Alchemy.register_ability(double(name: "MyAbility")) }

      it "calls config.abilities.add" do
        expect(Alchemy.config.abilities).to receive(:add)
        subject
      end
    end

    describe ".registered_abilities" do
      subject { Alchemy.registered_abilities }

      it "calls out to config.abilities" do
        expect(Alchemy.config).to receive(:abilities)
        subject
      end
    end
  end
end
