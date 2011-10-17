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
		name "A Public Page"
		page_layout "standard"
		language :language
		
		factory :public_page do
		  public true
	  end
		
	end
	
	factory :element do
	  name 'article'
  end
	
end
