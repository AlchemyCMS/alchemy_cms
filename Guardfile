# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'spork', :cucumber_env => { 'RAILS_ENV' => 'test' }, :rspec_env => { 'RAILS_ENV' => 'test' } do
  watch(%r{lib/})
  watch('spec/dummy/config/application.rb')
  watch('spec/dummy/config/environment.rb')
  watch(%r{^spec/dummy/config/environments/.+\.rb$})
  watch(%r{^spec/dummy/config/initializers/.+\.rb$})
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('spec/factories.rb')
  watch('spec/spec_helper.rb') { :rspec }
  watch('test/test_helper.rb') { :test_unit }
  watch(%r{features/support/}) { :cucumber }
end
