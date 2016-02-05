require 'factory_girl'
require 'alchemy/test_support/factories/language_factory'

FactoryGirl.define do

  factory :alchemy_page, class: 'Alchemy::Page' do
    language do Alchemy::Language.default || FactoryGirl.create(:alchemy_language) end
    sequence(:name) do |n| "A Page #{n}" end
    page_layout "standard"

    parent_id do
      (Alchemy::Page.find_by(language_root: true) ||
        FactoryGirl.create(:alchemy_page, :language_root)).id
    end

    # This speeds up creating of pages dramatically.
    # Pass do_not_autogenerate: false to generate elements
    do_not_autogenerate true

    trait :language_root do
      name 'Startseite'
      page_layout do language.page_layout end
      language_root true
      public true
      parent_id { Alchemy::Page.root.id }
    end

    trait :public do
      sequence(:name) do |n| "A Public Page #{n}" end
      public true
    end

    trait :system do
      name "Systempage"
      parent_id do Alchemy::Page.root.id end
      language_root false
      page_layout nil
      language nil
    end

    trait :restricted do
      name "Restricted page"
      restricted true
    end
  end
end
