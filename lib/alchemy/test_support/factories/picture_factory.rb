require 'factory_girl'

FactoryGirl.define do

  factory :alchemy_picture, class: 'Alchemy::Picture' do
    image_file File.new(File.expand_path('../../../../../spec/fixtures/image.png', __FILE__))
    name 'image'
    image_file_name 'image.png'
    upload_hash Time.now.hash
  end
end
