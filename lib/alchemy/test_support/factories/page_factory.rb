require 'factory_girl'
require 'alchemy/test_support/factories/language_factory'

FactoryGirl.define do

  factory :alchemy_page, class: 'Alchemy::Page' do
    language { Alchemy::Language.default }
    sequence(:name) { |n| "A Page #{n}" }
    page_layout "standard"

    # This speeds up creating of pages dramatically.
    # Pass do_not_autogenerate: false to generate elements
    do_not_autogenerate true

    trait :public do
      sequence(:name) { |n| "A Public Page #{n}" }
      public true
    end

    trait :system do
      name "Systempage"
      page_layout nil
      language nil
    end

    trait :restricted do
      name "Restricted page"
      restricted true
    end
  end
end
