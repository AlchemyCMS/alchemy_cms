FactoryBot.define do
  factory :alchemy_user, class: 'Alchemy::User' do
    sequence(:login) { |n| "john_#{n}.doe" }
    sequence(:email) { |n| "john_#{n}@doe.com" }
    firstname 'John'
    lastname 'Doe'
    password 's3cr3t'
    password_confirmation 's3cr3t'

    factory :alchemy_admin_user do
      alchemy_roles 'admin'
    end

    factory :alchemy_member_user do
      alchemy_roles 'member'
    end

    factory :alchemy_author_user do
      alchemy_roles 'author'
    end

    factory :alchemy_editor_user do
      alchemy_roles 'editor'
    end
  end
end
