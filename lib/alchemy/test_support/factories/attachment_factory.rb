require 'factory_girl'

FactoryGirl.define do
  factory :alchemy_attachment, class: 'Alchemy::Attachment' do
    file File.new(Alchemy::Engine.root.join('lib', 'alchemy', 'test_support', 'fixtures', 'image.png'))
    name 'image'
    file_name 'image.png'
  end
end
