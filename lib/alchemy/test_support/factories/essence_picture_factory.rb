require 'factory_girl'
require 'alchemy/test_support/factories/picture_factory'

FactoryGirl.define do

  factory :alchemy_essence_picture, class: 'Alchemy::EssencePicture' do
    picture factory: :alchemy_picture
  end
end
