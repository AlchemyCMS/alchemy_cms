module Alchemy
  module Upgrader::TwoPointFive

  private
  
    def convert_picture_storage
      desc "Convert the picture storage"
      converted_images = []
      images = Dir.glob Rails.root.join 'uploads/pictures/**/*.*'
      if images.blank?
        log "No pictures found", :skip
      else
        images.each do |image|
          image_uid = image.gsub(/#{Rails.root.to_s}\/uploads\/pictures\//, '')
          image_id = image_uid.split('/').last.split('.').first
          picture = Alchemy::Picture.find_by_id(image_id)
          if picture && picture.image_file_uid.blank?
            picture.image_file_uid = image_uid
            picture.image_file_size = File.new(image).size
            if picture.save!
              log "Converted #{image_uid}"
            end
          else
            log "Picture with id #{image_id} not found or already converted.", :skip
          end
        end
      end
    end

    def removed_standard_set_notice
      warn = <<-WARN
We removed the standard set from Alchemy core!
In order to get the standard set back, install the `alchemy-demo_kit` gem.
WARN
      todo warn
    end

    def renamed_t_method
      warn = <<-WARN
We renamed alchemy's `t` method override into `_t` to avoid conflicts with Rails own t method!
If you use the `t` method to translate alchemy scoped keys, then you have to use the `_t` method from now on.
WARN
      todo warn
    end

    def migrated_to_devise
      warn = <<-WARN
We changed the authentication provider from Authlogic to Devise.

If you are upgrading from an old Alchemy version < 2.5.0, then you have to make changes to your Devise configuration.

1. Run:

$ rails g alchemy:devise

And alter the encryptor to authlogic_sha512
and the stretches value from 10 to 20

# config/initializers/devise.rb
config.stretches = Rails.env.test? ? 1 : 20
config.encryptor = :authlogic_sha512

2. Add the encryptable module to your Alchemy config.yml:

# config/alchemy/config.yml
devise_modules:
  - :database_authenticatable
  - :trackable
  - :validatable
  - :timeoutable
  - :recoverable
  - :encryptable

WARN
      todo warn
    end
    
  end
end
