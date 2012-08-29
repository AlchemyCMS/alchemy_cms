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
    name 'Deutsch'
    code 'de'
    default true
    frontpage_name 'Intro'
    page_layout 'intro'
    public true

    factory :klingonian do
      name 'Klingonian'
      code 'kl'
      frontpage_name 'Tuq'
      default false
    end

    factory :english do
      name 'English'
      code 'en'
      frontpage_name 'Intro'
      default false
    end
  end

  factory :page, :class => 'Alchemy::Page' do

    language { Alchemy::Language.get_default || FactoryGirl.create(:language) }
    sequence(:name) { |n| "A Page #{n}" }
    parent_id { (Alchemy::Page.find_by_language_root(true) || FactoryGirl.create(:language_root_page)).id }
    page_layout "standard"

    # This speeds up creating of pages dramatically. Pass :do_not_autogenerate => false to generate elements
    do_not_autogenerate true

    factory :language_root_page do
      name 'Startseite'
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
    create_contents_after_create false
  end

  factory :picture, :class => 'Alchemy::Picture' do
    image_file File.new(File.expand_path('../support/image.png', __FILE__))
    name 'image'
    image_filename 'image.png'
    upload_hash Time.now.hash
  end

end
