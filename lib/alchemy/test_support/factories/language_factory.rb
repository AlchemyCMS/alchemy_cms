# frozen_string_literal: true

FactoryBot.define do
  factory :alchemy_language, class: "Alchemy::Language" do
    name { "Your Language" }
    code { ::I18n.available_locales.first.to_s }
    default { true }
    frontpage_name { "Intro" }
    page_layout { Alchemy::Config.get(:default_language)["page_layout"] }

    public { true }

    site { Alchemy::Site.default || create(:alchemy_site, :default) }

    trait :klingon do
      name { "Klingon" }
      code { "kl" }
      frontpage_name { "Tuq" }
      default { false }
    end

    trait :english do
      name { "English" }
      code { "en" }
      default { false }
    end

    trait :german do
      name { "Deutsch" }
      code { "de" }
      default { false }
    end
  end
end
