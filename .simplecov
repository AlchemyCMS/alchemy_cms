SimpleCov.adapters.define 'alchemy' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/bin/'
  add_filter '/script/'

  add_group 'Controllers', 'app/controllers/alchemy'
  add_group 'Models', 'app/models/alchemy'
  add_group 'Mailers', 'app/mailers/alchemy'
  add_group 'Helpers', 'app/helpers/alchemy'
  add_group 'Sweepers', 'app/sweepers'
  add_group 'Libraries', 'lib'
end