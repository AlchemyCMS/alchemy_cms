FactoryGirl.define do
	
	factory :user do
		email 'john@doe.com'
		login "jdoe"
		password 's3cr3t'
		password_confirmation 's3cr3t'
	end
	
	factory :admin, :parent => :user do
		role "admin"
	end
	
	factory :registered_user, :parent => :user do
		role "registerted"
	end
	
	factory :author, :parent => :user do
		role "author"
	end
	
	factory :admin, :parent => :user do
		role "editor"
	end
	
	factory :language do
		name 'Klingonian'
		code 'kl'
		default true
		frontpage_name 'tuq'
		page_layout 'intro'
	end
	
	factory :page do
		name "intro"
		page_layout "standard"
		language Factory.create(:language)
	end
	
	factory :public_page, :parent => :page do
		public true
	end
	
end
