FactoryGirl.define do

  factory :user, :class => 'Alchemy::User' do
    email 'john@doe.com'
    login "jdoe"
    password 's3cr3t'
    password_confirmation 's3cr3t'

    factory :admin_user do
      role "admin"
    end

    factory :registered_user do
      role "registered"
    end

    factory :author_user do
      role "author"
    end

    factory :editor_user do
      role "editor"
    end

  end

  factory :language, :class => 'Alchemy::Language' do
    language_code "kl"
    name 'Klingonian'
    default false
    frontpage_name 'Tuq'
    page_layout 'intro'
    public true

    factory :language_with_country_code do
      country_code 'cr'
    end
  end

  factory :page, :class => 'Alchemy::Page' do

    language { Alchemy::Language.find_by_language_code('kl') || FactoryGirl.create(:language) }
    sequence(:name) { |n| "A Page #{n}" }
    parent_id { (Alchemy::Page.find_by_language_root(true) || FactoryGirl.create(:language_root_page)).id }
    page_layout "standard"

    factory :language_root_page do
      name 'Klingonian'
      page_layout 'intro'
      language_root true
      public true
      parent_id { Alchemy::Page.root.id }
    end

    factory :public_page do
      sequence(:name) { |n| "A Public Page #{n}" }
      public true
    end

    factory :systempage do
      name "Systempage"
      parent_id { Alchemy::Page.root.id }
      language_root false
      page_layout nil
      language nil
    end

  end

  factory :cell, :class => 'Alchemy::Cell' do
    page { Alchemy::Page.find_by_language_root(true) || FactoryGirl.create(:language_root_page) }
    name "A Cell"
  end

  factory :element, :class => 'Alchemy::Element' do
    name 'article'
  end

  factory :picture, :class => 'Alchemy::Picture' do
    image_file File.new('../../support/image.png')
  end

end
