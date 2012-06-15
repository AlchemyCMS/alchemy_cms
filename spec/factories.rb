FactoryGirl.define do

	factory :user do
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

	factory :language do
		code "kl"
		name 'Klingonian'
		default false
		frontpage_name 'Tuq'
		page_layout 'intro'
		public true
	end

	factory :page do
		language { Language.find_by_code('kl') || FactoryGirl.create(:language) }
		name "A Page"
		parent_id { FactoryGirl.create(:language_root_page).id }
		page_layout "standard"

    factory :language_root_page do
  		name 'Klingonian'
  		page_layout 'intro'
  		language_root true
  		public true
  		parent_id { Page.root.id }
  	end

		factory :public_page do
  		name "A Public Page"
		  public true
	  end

	end

	factory :cell do
		page { Page.find_by_language_root(true) || FactoryGirl.create(:language_root_page) }
		name "A Cell"
	end

	factory :element do
	  name 'article'
  end

end
