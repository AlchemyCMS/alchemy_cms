require 'factory_bot'
require 'alchemy/test_support/factories/picture_factory'

FactoryBot.define do
  factory :alchemy_essence_picture, class: 'Alchemy::EssencePicture' do
    picture factory: :alchemy_picture
  end
end
