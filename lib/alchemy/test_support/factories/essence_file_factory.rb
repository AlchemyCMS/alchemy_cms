require 'factory_girl'
require 'alchemy/test_support/factories/attachment_factory'

FactoryGirl.define do

  factory :alchemy_essence_file, class: 'Alchemy::EssenceFile' do
    attachment factory: :alchemy_attachment
  end
end
