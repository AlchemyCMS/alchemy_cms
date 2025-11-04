# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_language, class: "Alchemy::Language" do
    name { "Your Language" }
    language_code { "en" }
    locale { ::I18n.default_locale }
    default { true }
    frontpage_name { "Intro" }
    page_layout { Alchemy.config.default_language.page_layout }

    public { true }

    site { Alchemy::Site.first || create(:alchemy_site, :default) }

    trait :klingon do
      name { "Klingon" }
      language_code { "kl" }
      locale { :kl }
      frontpage_name { "Tuq" }
      default { false }
    end

    trait :english do
      name { "English" }
      language_code { "en" }
      locale { :en }
      default { false }
    end

    trait :german do
      name { "Deutsch" }
      language_code { "de" }
      locale { :de }
      default { false }
    end
  end
end
