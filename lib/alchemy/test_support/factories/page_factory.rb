require 'factory_girl'
require 'alchemy/test_support/factories/language_factory'

FactoryGirl.define do
  factory :alchemy_page, class: 'Alchemy::Page' do
    language { Alchemy::Language.default || FactoryGirl.create(:alchemy_language) }
    sequence(:name) { |n| "A Page #{n}" }
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
      page_layout { language.page_layout }
      language_root true
      public_on { Time.current }
      parent_id { Alchemy::Page.root.id }
    end

    trait :public do
      sequence(:name) { |n| "A Public Page #{n}" }
      public_on { Time.current }
    end

    trait :system do
      name "Systempage"
      parent_id { Alchemy::Page.root.id }
      language_root false
      page_layout nil
      language nil
    end

    trait :layoutpage do
      name "Footer"
      parent_id { Alchemy::Page.find_or_create_layout_root_for(Alchemy::Language.current.id).id }
      page_layout "footer"
    end

    trait :restricted do
      name "Restricted page"
      restricted true
    end
  end
end
